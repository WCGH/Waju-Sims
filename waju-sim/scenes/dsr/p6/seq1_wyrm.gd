# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

signal sequence_finished(party: Dictionary, next_sequence: int)

# Spell Dimensions
const WYRM_DONUT_INNER_RADIUS = 41.25
const WYRM_DONUT_OUTER_RADIUS = 65.0
const TETHER_MIN_LENGTH = 52.7
const WYRM_CONE_ANGLE = 25.21
const WYRM_CONE_LENGHT = 100.0 
const WYRM_TB_CONE_ANGLE = 55.0
const WYRM_TB_CONE_LENGTH = 100.0
const WYRM_TB_SOLO_AOE_RADIUS = 35.35
const WYRM_TB_SHARED_AOE_RADIUS = 15.0
const VOW_RADIUS := 10.0
const AA_RADIUS := 17.0
const WINGS_TB_RADIUS := 21.0
const DIVEBOMB_WIDTH := 45
const DIVEBOMB_LENGTH := 147.0

@export var vow_icon_scene: PackedScene

var nid_path := "res://scenes/enemies/p6/nid6.tscn"
var hra_path := "res://scenes/enemies/p6/hrae.tscn"

@onready var target_controller: TargetController = %TargetController
@onready var tether_controller: TetherController = %TetherController
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var seq_1_anim: AnimationPlayer = %Seq1Anim
@onready var target_cast_bar : TargetCastBar = %TargetCastBar
@onready var enemy_cast_bar : EnemyCastBar = %EnemyCastBar
@onready var fail_list : FailList = %FailList
@onready var enemies_layer: Node3D = %Enemies
@onready var boss_hp_warn: Label = %BossHPWarn
@onready var pc_positions := P6_Seq1_PC_Positions.pc_positions
@onready var npc_positions := P6_NPC_Positions.npc_positions

var db_positions := {
	"ne": Vector2(22.5, -73),
	"nw": Vector2(-22.5, -73),
	"n": Vector2(0, -73),
	"se": Vector2(22.5, 73),
	"sw": Vector2(-22.5, 73),
	"s": Vector2(0, 73)
}
var wing_positions := {
	"ne": Vector2(50, -22.5),
	"nw": Vector2(-50, -22.5),
	"se": Vector2(50, 22.5),
	"sw": Vector2(-50, 22.5)
}
var party : Dictionary
var party_tether : Dictionary
var tether_party_list: Array
var vow_target: PlayableCharacter
var orb_config: int
var quadrants := ["ne", "nw", "se", "sw"]
var quad_index: int
var tanks_close: bool
var nid: P6Boss
var hra: P6Boss
var tethers : Array
var seq_played := false


func _ready() -> void:
	# Preload assets
	ResourceLoader.load_threaded_request(nid_path, "PackedScene")
	ResourceLoader.load_threaded_request(hra_path, "PackedScene")
	tether_controller.preload_resources()
	ground_aoe_controller.preload_aoe(["line", "circle", "cone", "donut"])



func start_sequence(new_party: Dictionary) -> Signal:
	if new_party:
		initialize_party(new_party)
		seq_1_anim.play("seq1")
		seq_played = true
	return sequence_finished


# Shuffles new party and stores it in Dictionary.
func initialize_party(new_party: Dictionary) -> void:
	var party_list : Array = new_party.values()
	party = new_party
	# Pick vow and tether targets
	tether_party_list = party_list.slice(2, 8)
	var dps_party_list := party_list.slice(4, 8)
	randomize()
	vow_target = dps_party_list.pick_random()
	Global.vow_target_key = party.find_key(vow_target)
	assign_tethers()


func assign_tethers() -> void:
	tether_party_list.shuffle()
	for i in tether_party_list.size():
		if i < 3:
			party_tether["ice%d" % i] = tether_party_list[i]
		else:
			party_tether["fire%d" % (i - 3)] = tether_party_list[i]



## Start of timed sequence.

# 0:02 - Spawn in Nid and Hra.
func spawn_npcs() -> void:
	var nid_scene: PackedScene = ResourceLoader.load_threaded_get(nid_path)
	var hra_scene: PackedScene = ResourceLoader.load_threaded_get(hra_path)
	nid = nid_scene.instantiate()
	hra = hra_scene.instantiate()
	nid.rotation_degrees.y = 90
	hra.rotation_degrees.y = -90
	enemies_layer.add_child(nid)
	enemies_layer.add_child(hra)
	nid.move_to(npc_positions["nid_spawn"])
	hra.move_to(npc_positions["hra_spawn"])
	target_controller.add_targetable_npc(nid)
	target_controller.add_targetable_npc(hra)


# 0:02.25 - Move to prepositions
func move_wyrm_pre() -> void:
	for key: String in party:
		if key.contains("t"):
			party[key].move_to(pc_positions["wyrm1"]["tanks"])
		elif key.contains("h"):
			party[key].move_to(pc_positions["wyrm1"]["heal"]) 
		elif key.contains("m"):
			party[key].move_to(pc_positions["wyrm1"]["melee"]) 
		else:
			party[key].move_to(pc_positions["wyrm1"]["ranged"]) 


# 0:04.25 - Start Wyrm casts 6.5s (+anim). Spawn tethers. Randomize tank buster.
func wyrm1_cast() -> void:
	target_cast_bar.cast("Dread Wyrmsbreath", 6.5, nid)
	target_cast_bar.cast("Great Wyrmsbreath", 6.5, hra)
	enemy_cast_bar.start_cast_bar_1("Dread Wyrmsbreath", 6.5)
	enemy_cast_bar.start_cast_bar_2("Great Wyrmsbreath", 6.5)
	# Start casting animations
	nid.start_breath_cast()
	hra.start_breath_cast()
	# Spawn tethers
	for key: String in party_tether:
		if key.contains("ice"):
			tether_controller.spawn_tether(party_tether[key], hra,
				Color.LIGHT_BLUE, Color.WEB_PURPLE, TETHER_MIN_LENGTH, 0.2)
		else: # Nid tethers
			tether_controller.spawn_tether(party_tether[key], nid,
				Color.ORANGE, Color.WEB_PURPLE, TETHER_MIN_LENGTH, 0.2)


# 0:05.25 - Spawn donut aoe (0.25s anim)
func spawn_wyrm_donut() -> void:
	ground_aoe_controller.spawn_donut(Vector2.ZERO, WYRM_DONUT_INNER_RADIUS,
	WYRM_DONUT_OUTER_RADIUS, 5.5, Color.CORAL, [0, 0, "Wyrmsbreath Dynamo"], true)
	# Spawn tank buster orbs
	orb_config = randi_range(0, 2) # 2 = double TB
	if orb_config == 0 or orb_config == 2:
		#Nidhogg glow
		nid.toggle_glow()
	if orb_config == 1 or orb_config == 2:
		#Hrae glow
		hra.toggle_glow()

# 0:07.25 - Move to adjusted positions
func move_to_wyrm_pos() -> void:
	# Tanks
	if orb_config != 2:
		party["t1"].move_to(pc_positions["wyrm1"]["t1"])
		party["t2"].move_to(pc_positions["wyrm1"]["t2"])
	var adjusters := []
	if party_tether.find_key(party["h1"]).left(1) ==\
		party_tether.find_key(party["h2"]).left(1):
		adjusters.append("heal")
	if party_tether.find_key(party["m1"]).left(1) ==\
		party_tether.find_key(party["m2"]).left(1):
		adjusters.append("melee")
	if adjusters.size() == 1:
		adjusters.append("ranged")
	# Swap group 2 adjusters
	if adjusters.size() > 0:
		party[adjusters[0].left(1) + "2"].move_to(pc_positions["wyrm1"][adjusters[1]])
		party[adjusters[1].left(1) + "2"].move_to(pc_positions["wyrm1"][adjusters[0]])
	


func finish_breath_animation() -> void:
	hra.finish_cast()
	nid.finish_cast()


# 0:10.75 - Check tether distance, Spawn aoe cones (+tb)
func wyrm1_hit() -> void:
	# Check tether distance
	for tether: Tether in tether_controller.active_tethers:
		if !tether.last_frame_stretched:
			fail_list.add_fail("%s did not stretch tether." % tether.source.name)
		# Spawn Cone AoE's
		if tether.target == nid:
			ground_aoe_controller.spawn_cone(v2(tether.target.global_position),
				WYRM_CONE_ANGLE, WYRM_CONE_LENGHT, v2(tether.source.global_position),
				0.5, Color.ORANGE_RED, [2, 2, "Wyrmsbreath (Nidhogg)"])
		else: # Hrae cones
			ground_aoe_controller.spawn_cone(v2(tether.target.global_position),
				WYRM_CONE_ANGLE, WYRM_CONE_LENGHT, v2(tether.source.global_position),
				0.5, Color.SKY_BLUE, [2, 2, "Wyrmsbreath (Hrae)"])
	tether_controller.remove_all_tethers()
	# Spawn TB
	if orb_config == 0:
		# Nid only glow: T2 gets TB + cone from Nid
		ground_aoe_controller.spawn_circle(v2(party["t2"].global_position),
			WYRM_TB_SOLO_AOE_RADIUS, 0.5, Color.SKY_BLUE,
			[1, 1, "Wyrmsbreath Tank Buster(solo)", [party["t2"]]])
		ground_aoe_controller.spawn_cone(v2(nid.global_position),
			WYRM_TB_CONE_ANGLE, WYRM_TB_CONE_LENGTH, Vector2.ZERO,
			0.5, Color.ORANGE_RED, [0, 0, "Wyrmsbreath Center Cone"])
		nid.toggle_glow()
	elif orb_config == 1:
		# Hrae only glow: T1 gets TB + cone from Hrae
		ground_aoe_controller.spawn_circle(v2(party["t1"].global_position),
			WYRM_TB_SOLO_AOE_RADIUS, 0.5, Color.SKY_BLUE,
			[1, 1, "Wyrmsbreath Tank Buster(solo)", [party["t1"]]])
		ground_aoe_controller.spawn_cone(v2(hra.global_position),
			WYRM_TB_CONE_ANGLE, WYRM_TB_CONE_LENGTH, Vector2.ZERO,
			0.5, Color.AQUA, [0, 0, "Wyrmsbreath Center Cone."])
		hra.toggle_glow()
	else:
		# Double glow, shared TB on random tank, no cone.
		var tank_index := "t1" if randi() % 2 == 0 else "t2"
		ground_aoe_controller.spawn_circle(v2(party[tank_index].global_position),
			WYRM_TB_SHARED_AOE_RADIUS, 0.5, Color.MEDIUM_VIOLET_RED,
			[2, 2, "Wyrmsbreath Tank Buster(shared)"])
		nid.toggle_glow()
		hra.toggle_glow()


# 0:12.0 - Move to vow spread positions
func move_to_vow1() -> void:
	move_party_to("vow1")


# 0:18.25 - Vow aoe_hit + debuff (34s), put up HP warning
func vow1_hit() -> void:
	boss_hp_warn.visible = true
	ground_aoe_controller.spawn_circle(v2(vow_target.global_position),
		VOW_RADIUS, 0.3, Color.PURPLE, [1, 1, "Mortal Vow", [vow_target]])
	vow_target.add_debuff(vow_icon_scene, 34.0)

# 0:21.5 - Start AA cast (+anim), move to lp stacks, put up a random hp tether
func aa1_cast() -> void:
	target_cast_bar.cast("Akh Afah", 7.75, nid)
	target_cast_bar.cast("Akh Afah", 7.75, hra)
	enemy_cast_bar.start_cast_bar_1("Akh Afah", 7.75)
	enemy_cast_bar.start_cast_bar_2("Akh Afah", 7.75)
	# Start casting animations
	nid.start_up_cast()
	hra.start_up_cast()
	# Move to lp stacks
	for key: String in party:
		if key.right(1) == "1":
			party[key].move_to(pc_positions["aa"]["lp1"])
		else:
			party[key].move_to(pc_positions["aa"]["lp2"])
	# Random tether
	var rnd := randi_range(0, 2)
	if rnd == 0:
		tether_controller.spawn_tether(nid, hra, Color.PURPLE)
	elif rnd == 1:
		tether_controller.spawn_tether(nid, hra, Color.LIGHT_BLUE)


# 0:27.0 - Remove hp tether
func remove_tether() -> void:
	tether_controller.remove_all_tethers()
	boss_hp_warn.visible = false


# 0:29.25 - AA Hit (+anim)
func aa1_hit() -> void:
	ground_aoe_controller.spawn_circle(v2(party["h1"].global_position),
		AA_RADIUS, 0.3, Color.LIGHT_YELLOW, [4, 4, "Akh Afah"])
	ground_aoe_controller.spawn_circle(v2(party["h2"].global_position),
		AA_RADIUS, 0.3, Color.LIGHT_YELLOW, [4, 4, "Akh Afah"])


# 0:33.75 - Nidhogg jump
func nid_jump() -> void:
	nid.warp_out()
	target_controller.remove_targetable_npc(nid)

# 0:35.25 - Wings1 Cast 8.25 (+ up/down anim + glow), Nidhogg land + cast Cauterize
func wings1_cast() -> void:
	# Cast wings
	target_cast_bar.cast("Hallowed Wings", 8.25, hra)
	enemy_cast_bar.start_cast_bar_1("Hallowed Wings", 8.25)
	# Determine safe spots
	quad_index = randi_range(0, 3)
	tanks_close = randi() % 2 == 0
	
	toggle_wing_glow()
	# Up/Down anim
	if !tanks_close: # Tanks out, head up
		hra.start_up_cast()
	# Move Nid
	if quad_index == 1 or quad_index == 3:  
		# West safe spot, East dive
		if randi() % 2 == 0:
			# North to South
			nid.move_to(db_positions["ne"])
			look_at_v2(nid, db_positions["se"])
		else: # South to North
			nid.move_to(db_positions["se"])
			look_at_v2(nid, db_positions["ne"])
	else: # East safe spot, West dive
		if randi() % 2 == 0:
			# North to South
			nid.move_to(db_positions["nw"])
			look_at_v2(nid, db_positions["sw"])
		else: # South to North
			nid.move_to(db_positions["sw"])
			look_at_v2(nid, db_positions["nw"])
	# Show Nid and cast cauterize
	nid.warp_in()
	enemy_cast_bar.start_cast_bar_2("Cauterize", 8.25)


# 0:40.0 - Move to Wings safe spot
func move_to_wings_pos() -> void:
	var t_key := "t_near" if tanks_close else "t_far"
	for key: String in party:
		if key.contains("t"):
			party[key].move_to(pc_positions["wings1"][quadrants[quad_index]][t_key][key])
		else:
			party[key].move_to(pc_positions["wings1"][quadrants[quad_index]][t_key]["pt"])


func play_divebomb() -> void:
	nid.start_divebomb()
	if tanks_close: # Head down
		hra.finish_cast_down()
	else:
		hra.finish_cast()


# 0:43.5 - Wings/DB hit + proximity aoe's.
func wings1_hit() -> void:
	# Get two nearest targets to Hrae.
	var aoe_targets: Array
	if tanks_close:
		aoe_targets = get_two_nearest_players_to_vector(v2(hra.global_position))
	else:
		aoe_targets = get_two_farthest_players_from_vector(v2(hra.global_position))
	# Spawm Tank AoE's.
	ground_aoe_controller.spawn_circle(v2(party[aoe_targets[0]].global_position), WINGS_TB_RADIUS,
		0.3, Color.AQUA, [1, 1, "Hallowed Wings Tank Buster", [party[aoe_targets[0]]]])
	ground_aoe_controller.spawn_circle(v2(party[aoe_targets[1]].global_position), WINGS_TB_RADIUS,
		0.3, Color.AQUA, [1, 1, "Hallowed Wings Tank Buster", [party[aoe_targets[1]]]])
	# Spawn Wings Line AoE.
	if quad_index < 2: # South Wings hit.
		ground_aoe_controller.spawn_line(wing_positions["se"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, wing_positions["sw"], 0.3,
			Color.AQUA, [0, 0, "Hallowed Wings"])
	else: # North Wings hit.
		ground_aoe_controller.spawn_line(wing_positions["ne"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, wing_positions["nw"], 0.3,
			Color.AQUA, [0, 0, "Hallowed Wings"])
	# Spawn Divebomb AoE
	if quad_index == 0 or quad_index == 2: # West Divebomb.
		ground_aoe_controller.spawn_line(db_positions["nw"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, db_positions["sw"], 0.3,
			Color.ORANGE_RED, [0, 0, "Cauterize (divebomb)"])
	else: # East Divebomb.
		ground_aoe_controller.spawn_line(db_positions["ne"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, db_positions["se"], 0.3,
			Color.ORANGE_RED, [0, 0, "Cauterize (divebomb)"])
	toggle_wing_glow()
	

func toggle_wing_glow() -> void:
	if quad_index < 2:
		hra.toggle_left_wing()
	else:
		hra.toggle_right_wing()


# 0:47.0 - Move to vow pass positions (left or right).
func move_to_vow2() -> void:
	if quad_index < 2: # Spread out north
		move_party_to("vow2", "north")
	else:
		move_party_to("vow2", "south")
	# Move Vow to middle
	vow_target.move_to(Vector2(0, 1))
	# Respawn Nidhogg
	nid.move_to(Vector2(-50, 0))
	look_at_v2(nid, Vector2.ZERO)
	nid.warp_in()
	target_controller.add_targetable_npc(nid)


# 0:52.25 - First Vow pass (dps to T1) (34s), check + aoe
func vow_hit_2() -> void:
	# Spawn AoE
	var vow_hit: CircleAoe = ground_aoe_controller.spawn_circle(
		v2(vow_target.global_position), VOW_RADIUS, 0.3, Color.WEB_PURPLE,
		[2, 2, "Mortal Vow Pass", [vow_target, party["t1"]]])
	# Add debuff to targets hit
	var targets_hit: Array = await vow_hit.get_collisions()
	for pc: PlayableCharacter in targets_hit:
		if pc != vow_target:
			pc.add_debuff(vow_icon_scene, 34.0)


# 0:53 - Next Sequence
func next_sequence() -> void:
	sequence_finished.emit(party, 1)

# 0.54.25 - Spawn npcs if not already there, assign vow if new (32s)

# 0:55.25 - Wroth cast

## Utility methods

# Only used to move party to a dictionary with exact matching keys
func move_party_to(key_1: String, key_2: String = "") -> void:
	var pos_dict: Dictionary = pc_positions[key_1] if key_2 == "" else pc_positions[key_1][key_2]
	for key: String in party:
		party[key].move_to(pos_dict[key])


func get_two_nearest_players_to_vector(vec2 : Vector2) -> Array:
	var nearest := ""
	var second_nearest := ""
	var nearest_dist_sqrd := 0.0
	var second_nearest_dist_sqrd := 0.0
	for key: String in party:
		var pc: PlayableCharacter = party[key]
		var dist := v2(pc.global_position).distance_squared_to(vec2)
		if nearest_dist_sqrd == 0.0 or dist < nearest_dist_sqrd:
			second_nearest = nearest
			second_nearest_dist_sqrd = nearest_dist_sqrd
			nearest = key
			nearest_dist_sqrd = dist
		elif second_nearest_dist_sqrd == 0.0 or dist < second_nearest_dist_sqrd:
			second_nearest = key
			second_nearest_dist_sqrd = dist
	return [nearest, second_nearest]

func get_two_farthest_players_from_vector(vec2 : Vector2) -> Array:
	var farthest := ""
	var second_farthest := ""
	var farthest_dist_sqrd := 0.0
	var second_farthest_dist_sqrd := 0.0
	for key: String in party:
		var pc: PlayableCharacter = party[key]
		var dist := v2(pc.global_position).distance_squared_to(vec2)
		if dist > farthest_dist_sqrd:
			second_farthest = farthest
			second_farthest_dist_sqrd = farthest_dist_sqrd
			farthest = key
			farthest_dist_sqrd = dist
		elif  dist > second_farthest_dist_sqrd:
			second_farthest = key
			second_farthest_dist_sqrd = dist
	return [farthest, second_farthest]

# Rotates the vector by a multiple of 90 deg
func rotate_pos(pos : Vector2, rotation: float) -> Vector2:
	return pos.rotated(deg_to_rad(rotation))


# Converts Vector3(x,z) -> Vectors2
func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)


# Inverted 180 to correct P6 boss facing "backwards".
func look_at_v2(unit: Node3D, target: Vector2) -> void:
	unit.look_at(Vector3(target.x, 0, target.y))
	unit.rotate_y(deg_to_rad(180))
