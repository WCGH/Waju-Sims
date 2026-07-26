# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.


extends Node

# Spell Dimensions
const DEFAM_RADIUS := 50.0
const TWIST_DIVE_WIDTH := 25.0
const TWIST_DIVE_LENGTH := 110.0
const SPIN_WIDTH := 27.0
#const ASCALON_ANGLE_DEG := 30.0
#const ASCALON_LENGTH := 50.0
const DIVEBOMB_WIDTH := 50.0
const DIVEBOMB_LENGTH := 70.0
const LH_RADIUS := 10.0
const AP_RADIUS := 15.0
const LIGHTNING_RADIUS := 10.0
const EMPTY_INNER_RADIUS = 12.0
const EMPTY_OUTTER_RADIUS = 60.0

@export var thunder_icon_scene : PackedScene

@onready var thordan: Node3D = %Thordan
@onready var thordan_model: Node3D = %Thordan/ThordanModel
@onready var lockon_controller: LockonController = %LockonController
@onready var ground_aoe_controller : GroundAoeController = %GroundAoEController
@onready var puddle_controller : WrathPuddleController = %WrathPuddleController
@onready var wrath_anim_seq: AnimationPlayer = %WrathSeq
@onready var npc_positions: Dictionary = P5_Seq1_NPC_Positions.positions_db
@onready var pc_positions: Dictionary = P5_Seq1_PC_Positions.positions_db
@onready var cast_bar: CastBar = get_tree().get_first_node_in_group("cast_bar")
@onready var enemy_cast_bar: EnmityCastBar = get_tree().get_first_node_in_group("clone_cast_bar")
@onready var fail_list: FailList = get_tree().get_first_node_in_group("fail_list")
@onready var enemies_layer: Node = get_tree().get_first_node_in_group("enemies_layer")
@onready var npcs := {
	"ign" : ser_ignasse, "vel" : ser_vellguine,
	"gri" : ser_grinnaux, "cha" : ser_charibert,
	"dar" : darkscale, "ved" : vedrfolnir, "vid" : vidofnir 
	}
@onready var npcs_dict := {
	"ign" : {"scale": 5.0, "path": "uid://bo0qg6b5yvx5a"},
	"vel" : {"scale": 5.0, "path": "uid://do2t4evaju7hv"},
	"gri" : {"scale": 5.0, "path": "uid://c4y7lggkfo65p"},
	"cha" : {"scale": 5.0, "path": "uid://lpsi2x11kshu"},
	"dar" : {"scale": 1.5, "path": "uid://0pklic0xk2vj"},
	"ved" : {"scale": 3.0, "path": "uid://beklndn0swthy"},
	"vid" : {"scale": 1.5, "path": "uid://d2qg85fispb37"}
}
var ser_ignasse: Node3D
var ser_vellguine: Node3D
var ser_grinnaux: Node3D
var ser_charibert: Node3D
var vidofnir: Node3D
var vedrfolnir: Node3D
var darkscale: Node3D
var tether_path := "uid://jl8oj6r0qdvu"

var party: Dictionary
var rtd_npc_positions: Dictionary
var rtd_pc_positions: Dictionary
var twister_snapshots: Array
var divebomb_pos: Vector2
var grin_north := true
var arena_rotation := 0.0
var player: Player


func _ready() -> void:
	puddle_controller.ap_dropped.connect(on_ap_dropped)
	puddle_controller.lh_dropped.connect(on_lh_dropped)


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	# Pre-load resources.
	lockon_controller.pre_load([LockonController.DEFAM, LockonController.DIVEBOMB])
	initialize_party(new_party)
	wrath_anim_seq.play("wrath_sequence")


# Shuffles new party and stores it in Dictionary.
func initialize_party(new_party: Dictionary) -> void:
	var party_list: Array = new_party.values()
	randomize()
	party_list.shuffle()
	
	# Select Lightning targets
	var l1_index := randi_range(0, 7)
	var l2_index := l1_index
	while l2_index == l1_index:
		l2_index = randi_range(0, 7)
	
	# Select AP and LH targets
	var ap_index := l1_index
	var lh_index := l1_index
	while ap_index == l1_index or ap_index == l2_index:
		ap_index = randi_range(0, 3)
	while lh_index == l1_index or lh_index == l2_index:
		lh_index = randi_range(4, 7)
	
	# Swap player with ap or lh
	if DsrGlobal.player_puddles:
		player = get_tree().get_first_node_in_group("player")
		var player_index := party_list.find(player)
		if player_index < 4 and player_index != ap_index:
			var bot: PlayableCharacter = party_list[ap_index]
			party_list[ap_index] = player
			party_list[player_index] = bot
		elif player_index > 3 and player_index != lh_index:
			var bot: PlayableCharacter = party_list[lh_index]
			party_list[lh_index] = player
			party_list[player_index] = bot
	
	# Populate dictionary
	party = {
		"pre": {
			"t1": party_list[0],
			"t2": party_list[1],
			"def": party_list[2],
			"dive": party_list[3],
			"free1": party_list[4],
			"free2": party_list[5],
			"free3": party_list[6],
			"free4": party_list[7]
		},
		 #Post-cleave
		"post": {
			"l1": party_list[l1_index],
			"l2": party_list[l2_index],
			"ap": party_list[ap_index],
			"lh": party_list[lh_index]
		}
	}
	# Add remaining post-cleave characters (no debuff)
	var count := 1
	for i in party_list.size():
		if i == l1_index or i == l2_index or i == ap_index or i== lh_index:
			continue
		party["post"]["free%d" % count] = party_list[i]
		count += 1


func load_npcs_threaded() -> void:
	for key: String in npcs_dict:
		ResourceLoader.load_threaded_request(npcs_dict[key]["path"], "PackedScene")
	ResourceLoader.load_threaded_request(tether_path)


func instantiate_npcs() -> void:
	for key: String in npcs_dict:
		var npc_scene: PackedScene = ResourceLoader.load_threaded_get(npcs_dict[key]["path"])
		var new_npc: Enemy = npc_scene.instantiate()
		new_npc.visible = false
		new_npc.scale = Vector3.ONE * npcs_dict[key]["scale"]
		enemies_layer.add_child(new_npc)
		npcs_dict[key]["node"] = new_npc
		npcs[key] = new_npc
	
	# Assign NPCs
	ser_ignasse = npcs["ign"]
	ser_vellguine = npcs["vel"]
	ser_grinnaux = npcs["gri"]
	ser_charibert = npcs["cha"]
	vidofnir = npcs["vid"]
	vedrfolnir = npcs["ved"]
	darkscale = npcs["dar"]
	
	# Add tether scenes to Ignasse and Vellguine
	var tether_scene: PackedScene = ResourceLoader.load_threaded_get(tether_path)
	var ign_tether: Node3D = tether_scene.instantiate()
	var vel_tether: Node3D = tether_scene.instantiate()
	ign_tether.visible = false
	vel_tether.visible = false
	ser_ignasse.add_child(ign_tether)
	ser_vellguine.add_child(vel_tether)


## Start of timed sequence.

## 11:50
# Cast Wrath (3.5s), Randomize positions and move npcs to starting points 
func cast_wrath() -> void:
	cast_bar.cast("Wrath of the Heavens", 3.5)
	load_npcs_threaded()


func jump_thordan() -> void:
	instantiate_npcs()
	randomize_positions()
	thordan_model.start_jump()


## 11:57
# Hide Thordan, Move Knights + Dragons
func move_knights() -> void:
	thordan.visible = false
	# Move NPCs
	for key: String in npcs:
		if key == "gri":
			if grin_north:
				npcs[key].move_enemy(rtd_npc_positions["pos1"]["north"])
			else:
				npcs[key].move_enemy(rtd_npc_positions["pos1"]["south"])
		elif key == "cha":
			if grin_north:
				npcs[key].move_enemy(rtd_npc_positions["pos1"]["south"])
			else:
				npcs[key].move_enemy(rtd_npc_positions["pos1"]["north"])
		else:
			npcs[key].move_enemy(rtd_npc_positions["pos1"][key])
		# Turn to face middle
		npcs[key].look_at(Vector3.ZERO)


## 11:58
# Show Knights + Vedr
func show_knights() -> void:
	ser_ignasse.visible = true
	ser_vellguine.visible = true
	vedrfolnir.visible = true

## 11:59
# Set tethers active and show, Show defam marker, Start Twisting Dive Cast (enemy, 6s)
func set_tethers() -> void:
	ser_vellguine.activate_tether(party["pre"]["t1"])
	ser_ignasse.activate_tether(party["pre"]["t2"])
	#party["pre"]["def"].toggle_marker_defam()
	lockon_controller.add_marker(LockonController.DEFAM, party["pre"]["def"])
	enemy_cast_bar.cast("Twisting Dive", 6.0)

## 11:59.75
# Move to pre-twister position
# Show Darkscale + Vidofnir
func move_to_pos1() -> void:
	# Move bots, randomize East side positions so Divebomb is at a random position
	var east_positions := [rtd_pc_positions["pre"]["dive"], rtd_pc_positions["pre"]["pre1"],
	rtd_pc_positions["pre"]["pre2"], rtd_pc_positions["pre"]["pre3"], rtd_pc_positions["pre"]["pre4"]]
	east_positions.shuffle()
	for key: String in party["pre"]:
		var pc: PlayableCharacter = party["pre"][key]
		#if pc.is_player():
			#continue
		if key.contains("free") or key == "dive":
			var pos: Vector2 = east_positions.pop_back()
			pc.move_to(pos)
		else:
			pc.move_to(rtd_pc_positions["pre"][key])
	# Show E/W Dragons
	darkscale.visible = true
	vidofnir.visible = true

## 12:04
# Spawn thunder debuffs
func add_thunder() -> void:
	party["post"]["l1"].add_debuff(thunder_icon_scene)
	ground_aoe_controller.spawn_circle(v2(party["post"]["l1"].global_position),
		4, 0.25, Color.MEDIUM_PURPLE)
	party["post"]["l2"].add_debuff(thunder_icon_scene)
	ground_aoe_controller.spawn_circle(v2(party["post"]["l2"].global_position),
		4, 0.25, Color.MEDIUM_PURPLE)

## 12:05
# Show Grin+Chari
func show_grinchar() -> void:
	ser_grinnaux.visible = true
	ser_charibert.visible = true


func play_divebomb() -> void:
	vedrfolnir.play_divebomb()


## 12:06
# Show Divebomb marker, Spawn Twisting Dive, Spin, Defamation 
# Snapshot twisters, Show Thordan, Move bots
func spawn_multi_aoe() -> void:
	lockon_controller.add_marker(LockonController.DIVEBOMB, party["pre"]["dive"])
	ser_vellguine.remove_tether()
	ser_ignasse.remove_tether()
	# Twisting Dive.
	ground_aoe_controller.spawn_line(v2(vedrfolnir.global_position), TWIST_DIVE_WIDTH,
	TWIST_DIVE_LENGTH, Vector2.ZERO, 0.5, Color.ORANGE_RED, [0, 0, "Twisting Dive"])
	#vedrfolnir.visible = false
	# Vellguine Spin.
	var vel_target := v2(party["pre"]["t1"].global_position)
	var vel_dist := v2(ser_vellguine.global_position).distance_to(vel_target)
	ground_aoe_controller.spawn_line(v2(ser_vellguine.global_position), SPIN_WIDTH,
	 vel_dist, vel_target, 0.4, Color.ORANGE, [0, 1,
	"Tether Spin (Vellguine)", [party["pre"]["t1"]]])
	# Ignase Spin.
	var ign_target := v2(party["pre"]["t2"].global_position)
	var ign_dist := v2(ser_ignasse.global_position).distance_to(ign_target)
	ground_aoe_controller.spawn_line(v2(ser_ignasse.global_position), SPIN_WIDTH,
	 ign_dist, ign_target, 0.4, Color.ORANGE, [0, 1,
	"Tether Spin (Ignase)", [party["pre"]["t2"]]])
	ser_vellguine.visible = false
	ser_ignasse.visible = false
	# Defamation
	var defam: PlayableCharacter = party["pre"]["def"]
	lockon_controller.remove_marker(LockonController.DEFAM, defam)
	ground_aoe_controller.spawn_circle(v2(defam.global_position), DEFAM_RADIUS, 0.4,
	Color.DARK_BLUE, [1, 1, "Defamation", [defam]])
	# Twister Snapshot
	for key: String in party["pre"]:
		twister_snapshots.append(v2(party["pre"][key].global_position))
	thordan.visible = true
	# Move bots
	for key: String in party["pre"]:
		var character : CharacterBody3D = party["pre"][key]
		if key.contains("free"):
			var dest := character.global_position.move_toward(Vector3.ZERO, 10.0)
			character.move_to(v2(dest))
		elif key == "dive":
			if grin_north:
				character.move_to(rtd_pc_positions["cleave"]["dive_gn"])
			else:
				character.move_to(rtd_pc_positions["cleave"]["dive_gs"])
		else:
			character.move_to(rtd_pc_positions["cleave"][key])

## 12:07.25
# Spawn twisters
func spawn_twisters() -> void:
	for twister_pos: Vector2 in twister_snapshots:
		ground_aoe_controller.spawn_twister(twister_pos, 3.8, [0, 0, "Twister"])
	# Start Ascalon cast (3.5s)
	enemy_cast_bar.cast("Ascalon's Mercy Revealed", 3.5)

## 12:11
# Spawn cone AoE's
# Snapshot Divebomb position, remove marker
# Despawn twisters
func spawn_ascalon() -> void:
	# Ascalon cones
	for key: String in party["pre"]:
		var target: PlayableCharacter = party["pre"][key]
		ground_aoe_controller.spawn_ascalon_cone(Vector2.ZERO, v2(target.global_position),
		0.4, Color.CORAL, [1, 1, "Ascalon's Mercy (Cone)", [target]])
	# Snapshot Divebomb
	divebomb_pos = v2(party["pre"]["dive"].global_position)
	lockon_controller.remove_marker(LockonController.DIVEBOMB, party["pre"]["dive"])


## 12:11.5
# Start LH/AP hits
func lh_ap_hits() -> void:
	puddle_controller.start_ap_lh_seq(party["post"]["ap"], party["post"]["lh"], arena_rotation)
	# Move Bots
	var direction := "n" if grin_north else "s"
	for key: String in party["post"]:
		if key.contains("free"):
			party["post"][key].move_to(rtd_pc_positions["post"]["stack%s" % direction])
		elif key == "l1" or key == "l2":
			party["post"][key].move_to(rtd_pc_positions["post"]["%s%s" % [key, direction]])


func on_ap_dropped() -> void:
	if grin_north:
		party["post"]["ap"].move_to(rtd_pc_positions["post"]["stackn"])
	else:
		party["post"]["ap"].move_to(rtd_pc_positions["post"]["stacks"])


func on_lh_dropped() -> void:
	if grin_north:
		party["post"]["lh"].move_to(rtd_pc_positions["post"]["stackn"])
	else:
		party["post"]["lh"].move_to(rtd_pc_positions["post"]["stacks"])


## 12:14
# Start Empty Dimension cast (4.5s)
func cast_empty() -> void:
	enemy_cast_bar.cast("Empty Dimension", 4.5)

## 12:18
# Empty Dimension hit
# Lightnings hit
# Divebombs hit
func empty_hit() -> void:
	# Empty dimension.
	ground_aoe_controller.spawn_donut(v2(ser_grinnaux.global_position),
	EMPTY_INNER_RADIUS, EMPTY_OUTTER_RADIUS, 0.7, Color.WEB_PURPLE, [0, 0, "Empty Dimension"])
	# Thunder hits.
	var l1: PlayableCharacter = party["post"]["l1"]
	ground_aoe_controller.spawn_circle(v2(l1.global_position), LIGHTNING_RADIUS, 0.4,
	Color.PURPLE, [1, 1, "Thunder", [l1]])
	var l2: PlayableCharacter = party["post"]["l2"]
	ground_aoe_controller.spawn_circle(v2(l2.global_position), LIGHTNING_RADIUS, 0.4,
	Color.PURPLE, [1, 1, "Thunder", [l2]])
	# Divebomb hit
	ground_aoe_controller.spawn_line(v2(darkscale.global_position), DIVEBOMB_WIDTH,
	DIVEBOMB_LENGTH, divebomb_pos, 0.4, Color.ORANGE_RED, [0, 0, "Divebomb"])
	ground_aoe_controller.spawn_line(v2(vidofnir.global_position), DIVEBOMB_WIDTH,
	DIVEBOMB_LENGTH, divebomb_pos, 0.4, Color.ORANGE_RED, [0, 0, "Divebomb"])
## End of Timed sequence


## Utility methods

# Randomizes the variable npc spawn positions, rotates the position dictionary
func randomize_positions() -> void:
	grin_north = randi() % 2 == 0
	arena_rotation = 90.0 * randi_range(0, 3)
	# Copy to new dictionary with rotated vectors
	rtd_pc_positions = pc_positions.duplicate(true)
	rtd_npc_positions = npc_positions.duplicate(true)
	if arena_rotation == 0.0:
		return
	for pos_key: String in pc_positions:
		for pc_key: String in pc_positions[pos_key]:
			rtd_pc_positions[pos_key][pc_key] = rotate_pos(pc_positions[pos_key][pc_key])
	for pos_key: String in npc_positions:
		for npc_key: String in npc_positions[pos_key]:
			rtd_npc_positions[pos_key][npc_key] = rotate_pos(npc_positions[pos_key][npc_key])


# Rotates the vector by a multiple of 90 deg
func rotate_pos(pos : Vector2) -> Vector2:
	return pos.rotated(deg_to_rad(arena_rotation))


# Converts Vector3(x,z) -> Vectors2
func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
