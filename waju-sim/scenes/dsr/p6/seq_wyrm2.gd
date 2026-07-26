# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends P6Sequence

const TOUCHDOWN_RADIUS = 35.0
const BOILING_DEBUFF_DURATION = 10.0
const WYRM_DIVEBOMB_WIDTH := 50.0

@export var boiling_icon_scene: PackedScene
@export var freezing_icon_scene: PackedScene
@export var pyretic_icon_scene: PackedScene
@export var deep_freeze_icon_scene: PackedScene

@onready var wyrm_2_anim: AnimationPlayer = %Wyrm2Anim
@onready var pc_positions := {
	"pre_pos": {
		"t1": Vector2(1, -7), "t2": Vector2(-1, -7),
		"h1": Vector2(0, 40), "h2": Vector2(0, -30),
		"m1": Vector2(-7, -20), "m2": Vector2(7, -20),
		"r1": Vector2(-3, -27), "r2": Vector2(6, -27)
	},
	"wyrm2": {
		"ice1": Vector2(-25.4, -31.1), "ice2": Vector2(-14, -37),
		"north": Vector2(0, -40), "south": Vector2(0, 40),
		"fire1": Vector2(25.4, -31.1), "fire2": Vector2(14, -37),
		"t1": Vector2(-31.28, 24.58), "t2": Vector2(31.28, 24.58)
	},
	"wyrm2_static": {
		"t1": Vector2(-31.5, -25.5), "t2": Vector2(31.5, 25.5),
		"h1": Vector2(0, -40), "h2": Vector2(0, 40),
		"m1": Vector2(-7.55, 21.2), "m2": Vector2(7.55, -21.2),
		"r1": Vector2(-15.5, 37.5), "r2": Vector2(15.5, -37.5)
	},
	"pre_db": {
		"t1": Vector2(-16.5, -42.7), "t2": Vector2(16.5, -42.7),
		"h1": Vector2(0, -20), "h2": Vector2(0, -35),
		"m1": Vector2(0, -22), "m2": Vector2(0, -28),
		"r1": Vector2(-0, -24), "r2": Vector2(0, -32)
	},
	"north_stack": Vector2(0, -41.8),
	"vow5": {
		"t1": Vector2(-4, -7), "t2": Vector2(-14, -7),
		"h1": Vector2(12, -18), "h2": Vector2(5, -20),
		"m1": Vector2(11, -20), "m2": Vector2(7, -25),
		"r1": Vector2(3, -27), "r2": Vector2(-5, -41.8)
		}
}

var party_tether: Dictionary
var position_keys: Dictionary
var variable_pos_keys := ["ice1", "ice2", "north", "fire1", "fire2"]
var ice_keys: Array
var fire_keys: Array
var orb_config: int
var npc_db_pos: Dictionary
var westhog: bool
var check_pyretic := false
var melee_vow_target: PlayableCharacter
var wb2_index: int

# Needed to avoid duplicate ready calls in parent.
func _ready() -> void:
	# Get strat variables
	wb2_index = DsrSavedVariables.get_data("p6", "wb_2")


func _physics_process(_delta: float) -> void:
	if check_pyretic:
		if player.velocity.length_squared() > 1.0:
			fail_list.add_fail("Player moved during Pyretic.")
			check_pyretic = false


func start_sub_sequence() -> void:
	print("Start of Wyrm2: ", test_timer.time_left)
	assign_tethers()
	wyrm_2_anim.play("wyrm2")


func assign_tethers() -> void:
	var tether_party_list : Array = party.values()
	tether_party_list = tether_party_list.slice(2, 8)
	randomize()
	tether_party_list.shuffle()
	for i in tether_party_list.size():
		if i < 3:
			party_tether["ice%d" % i] = tether_party_list[i]
			ice_keys.append(party.find_key(tether_party_list[i]))
		else:
			party_tether["fire%d" % (i - 3)] = tether_party_list[i]
			fire_keys.append(party.find_key(tether_party_list[i]))
	# Assign divebomb positions
	westhog = randi() % 2 == 0
	if westhog:
		npc_db_pos["nid"] = npc_positions["db"]["nw"]
		npc_db_pos["nid_tar"] = npc_positions["db"]["sw"]
		npc_db_pos["hra"] = npc_positions["db"]["ne"]
		npc_db_pos["hra_tar"] = npc_positions["db"]["se"]
	else:
		npc_db_pos["nid"] = npc_positions["db"]["ne"]
		npc_db_pos["nid_tar"] = npc_positions["db"]["se"]
		npc_db_pos["hra"] = npc_positions["db"]["nw"]
		npc_db_pos["hra_tar"] = npc_positions["db"]["sw"]


# 2.0 - Move to pre-pos.
func move_wyrm_pre() -> void:
	# 5N1S pre-positions
	if wb2_index == DsrSavedVariables.wb_2.FNOS:
		for key: String in party:
			party[key].move_to(pc_positions["pre_pos"][key])
	# Static positions
	else:
		for key: String in party:
			if key.contains("tank"):
				party[key].move_to(pc_positions["pre_pos"][key])
			else:
				party[key].move_to(pc_positions["wyrm2_static"][key])
			


# 3.4 - Start Wyrm casts 6.5s (+anim). Spawn tethers. Randomize tank buster.
func wyrm2_cast() -> void:
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


# 4.5 - Spawn donut aoe (0.25s anim)
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

# 6.0 - Move to adjusted positions
func move_to_wyrm_pos() -> void:
	# Static pos, move tanks.
	if wb2_index == DsrSavedVariables.wb_2.STATIC:
		if orb_config == 2:
			party["t1"].move_to(Vector2.ZERO)
			party["t2"].move_to(Vector2.ZERO)
		else:
			party["t1"].move_to(pc_positions["wyrm2_static"]["t1"])
			party["t2"].move_to(pc_positions["wyrm2_static"]["t2"])
		return
	
	# 5N1S
	# Tanks
	if orb_config != 2:
		party["t1"].move_to(pc_positions["wyrm2"]["t1"])
		party["t2"].move_to(pc_positions["wyrm2"]["t2"])
	# Healers
	var healers_same := is_same_tether("h1", "h2")
	if healers_same:
		position_keys["h2"] = "ice2" if is_ice("h2") else "fire2"
	else:
		position_keys["h2"] = "north"
	# Melee
	var melee_same := is_same_tether("m1", "m2")
	if melee_same:
		if is_ice("m1"):
			position_keys["m1"] = "ice2"
			position_keys["m2"] = "ice1"
		else:
			position_keys["m1"] = "fire2"
			position_keys["m2"] = "fire1"
	else:
		if is_ice("m1"):
			position_keys["m1"] = "ice1"
			position_keys["m2"] = "fire1"
		else:
			position_keys["m1"] = "fire1"
			position_keys["m2"] = "ice1"
	# Ranged 1 (simple adjust, does opposite of h2)
	if healers_same:
		# "Cursed pattern where all 3 are the same
		if is_same_tether("h2", "r1"):
			position_keys["r1"] = "ice1" if is_ice("r1") else "fire1"
			position_keys["r2"] = "north"
			move_to_tether_positions()
			return
		else:
			position_keys["r1"] = "north"
	else:
		position_keys["r1"] = "ice2" if is_ice("r1") else "fire2"
	# Ranged 2 (fills last open spot)
	for key: String in variable_pos_keys:
		if position_keys.find_key(key) == null:
			position_keys["r2"] = key
	move_to_tether_positions()


func move_to_tether_positions() -> void:
	for key: String in position_keys:
		party[key].move_to(pc_positions["wyrm2"][position_keys[key]])


func finish_breath_animation() -> void:
	hra.finish_cast()
	nid.finish_cast()


# 10.0 - Check tether distance, Spawn aoe cones (+tb)
func wyrm2_hit() -> void:
	# Check tether distance
	for tether: Tether in tether_controller.active_tethers:
		# Only check distance if 5N1S, assume mits are being used for Static.
		if wb2_index == DsrSavedVariables.wb_2.FNOS:
			if !tether.last_frame_stretched:
				fail_list.add_fail("%s did not stretch tether." % tether.source.name)
		# Spawn Cone AoE's
		if tether.target == nid:
			ground_aoe_controller.spawn_cone(v2(tether.target.global_position),
				WYRM_CONE_ANGLE, WYRM_CONE_LENGHT, v2(tether.source.global_position),
				0.5, Color.ORANGE_RED, [1, 1, "Wyrmsbreath (Nidhogg)"])
			tether.source.add_debuff(boiling_icon_scene, BOILING_DEBUFF_DURATION)
		else: # Hrae cones
			ground_aoe_controller.spawn_cone(v2(tether.target.global_position),
				WYRM_CONE_ANGLE, WYRM_CONE_LENGHT, v2(tether.source.global_position),
				0.5, Color.SKY_BLUE, [1, 1, "Wyrmsbreath (Hrae)"])
			tether.source.add_debuff(freezing_icon_scene, BOILING_DEBUFF_DURATION)
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


# 0:14.0 - Move to pre-divebomb positions
func move_to_pre_db() -> void:
	move_party_to("pre_db")


# 15.7
func warp_out_bosses() -> void:
	nid.warp_out()
	hra.warp_out()
	target_controller.remove_targetable_npc(nid)
	target_controller.remove_targetable_npc(hra)


# 16.9 - Warp in
func warp_in_bosses() -> void:
	nid.move_to(npc_db_pos["nid"])
	look_at_v2(nid, npc_db_pos["nid_tar"])
	hra.move_to(npc_db_pos["hra"])
	look_at_v2(hra, npc_db_pos["hra_tar"])
	nid.warp_in()
	hra.warp_in()


# 18.0 - Move dps/healers to safe sides
func move_to_db_positions() -> void:
	# Cast Cauterize
	enemy_cast_bar.start_cast_bar_1("Cauterize", 4.5)
	enemy_cast_bar.start_cast_bar_2("Cauterize", 4.5)
	# Shift dps/healers left or right.
	var movement_delta := Vector2(-10, 0) if westhog else Vector2(10, 0)
	for key: String in party_tether:
		if key.contains("ice"):
			party_tether[key].move_to(v2(party_tether[key].global_position) + movement_delta)
		else:
			party_tether[key].move_to(v2(party_tether[key].global_position) - movement_delta)


# 21.5 - Add debuffs (30s). Check movement
func apply_debuffs() -> void:
	# Tank Condition (don't apply debuff)
	if party_tether.find_key(player) == null:
		return
	
	# Handle player movement checks in _process().
	if party_tether.find_key(player).contains("fire") and !Global.spectate_mode:
		check_pyretic = true
	else:
		player.freeze_player()
	# Apply debuffs.
	for key: String in ice_keys:
		party[key].add_debuff(deep_freeze_icon_scene, 30.0)
	for key: String in fire_keys:
		party[key].add_debuff(pyretic_icon_scene, 30.0)

# 22.7
func start_db_anim() -> void:
	hra.start_divebomb()
	nid.start_divebomb()


# 23.8 - DB Hit, remove debuffs
func db_hit() -> void:
	ground_aoe_controller.spawn_line(npc_db_pos["hra"],
		WYRM_DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_db_pos["hra_tar"], 0.4,
		Color.PALE_TURQUOISE, [4, 4, "Cauterize (Hraesvelgr)"])
	ground_aoe_controller.spawn_line(npc_db_pos["nid"],
		WYRM_DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_db_pos["nid_tar"], 0.4,
		Color.ORANGE_RED, [4, 4, "Cauterize (Nidhogg)"])
	# Unfreeze and remove debuffs
	if check_pyretic:
		check_pyretic = false
	else:
		player.unfreeze_player()
	for key: String in ice_keys:
		party[key].remove_debuff("Deep Freeze")
	for key: String in fire_keys:
		party[key].remove_debuff("Pyretic")


# 25.0 - Move party to north stack.
func move_north() -> void:
	for key: String in party:
		party[key].move_to(pc_positions["north_stack"])


# 29.9 - Touchdown
func touchdown() -> void:
	ground_aoe_controller.spawn_circle(Vector2.ZERO, TOUCHDOWN_RADIUS, 0.3,
		Color.RED, [0, 0, "Touchdown"])


# 31.0 - Move party away from vow
func move_to_vow_5() -> void:
	melee_vow_target = party["m2"] if vow_target == party["m1"] else party["m1"]
	move_party_to("vow5")
	melee_vow_target.move_to(pc_positions["vow5"]["r2"])


# 33.4 - Vow aoe_hit + debuff (34s)
func vow_hit_5() -> void:
	# Spawn AoE
	var vow_hit: CircleAoe = ground_aoe_controller.spawn_circle(
		v2(melee_vow_target.global_position), VOW_RADIUS, 0.3, Color.WEB_PURPLE,
		[2, 2, "Mortal Vow Pass", [melee_vow_target, party["r2"]]])
	# Add debuff to targets hit
	var targets_hit: Array = await vow_hit.get_collisions()
	for pc: PlayableCharacter in targets_hit:
		if pc != melee_vow_target:
			pc.add_debuff(vow_icon_scene, 34.0)
	melee_vow_target.add_debuff(atonement_icon_scene, ATONEMENT_DURATION)


## Utility

func is_ice(key: String) -> bool:
	return ice_keys.has(key)


func is_same_tether(key1: String, key2: String) -> bool:
	return (ice_keys.has(key1) and ice_keys.has(key2)) or\
		(fire_keys.has(key2) and fire_keys.has(key1))


# Only used to move party to a dictionary with exact matching keys
func move_party_to(key_1: String, key_2: String = "") -> void:
	var pos_dict: Dictionary = pc_positions[key_1] if key_2 == "" else pc_positions[key_1][key_2]
	for key: String in party:
		party[key].move_to(pos_dict[key])
