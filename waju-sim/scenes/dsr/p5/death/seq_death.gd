# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Handles all timings and behaviour for DotH sequence.

extends Node

# Spell Dimensions

const CENTER_DIVEBOMB_WIDTH := 36.5
const CENTER_DIVEBOMB_LENGTH := 100.0
const SIDE_DIVEBOMB_WIDTH := 20.0
const SIDE_DIVEBOMB_LENGTH := 100.0
const CLEANSE_PUDDLE_RADIUS := 3.0
const CLEANSE_PUDDLE_GROW_RADIUS := 6.0
const CLEANSE_PUDDLE_DURATION := 20.0
const HELLFLAME_RADIUS := 16.0
const IMPACT_1_RADIUS := 12.2
const IMPACT_2_RADIUS := 25.3
const IMPACT_3_RADIUS := 38.0
const IMPACT_4_RADIUS := 51.0
const IMPACT_5_RADIUS := 64.0
const CHAINS_MIN_SNAP_DIST := 12.0
const KNOCKBACK_DIST := 34.0
const TETHER_BREAK_DIST := 70.0

@export var thordan_scene: PackedScene
@export var doom_icon_scene : PackedScene
@export var chains_icon_scene : PackedScene
@export var tether_scene : PackedScene

@onready var npcs : Dictionary = {
	"ign" : {"scale": 4.5, "path": "uid://bo0qg6b5yvx5a"}, 
	"grin" : {"scale": 4.5, "path": "uid://c4y7lggkfo65p"},
	"guer" : {"scale": 4.5, "path": "uid://dynnvmdagt0kn"},
	"char" : {"scale": 4.5, "path": "uid://lpsi2x11kshu"},
	"nod" : {"scale": 4.5, "path": "uid://lpsi2x11kshu"},
	"vedr" : {"scale": 2.0, "path": "uid://beklndn0swthy"},
	"vido" : {"scale": 1.5, "path": "uid://d2qg85fispb37"},
	"dark" : {"scale": 1.5, "path": "uid://0pklic0xk2vj"},
	"eye" : {"scale": 4.7, "path": "uid://c00affclda2tc"},
	"thor" : {"scale": 2.0, "path": "uid://cd1lcq832fme3"}
	}
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var death_anim_seq: AnimationPlayer = %DeathSeq
@onready var npc_positions: Dictionary = P5_Seq2_NPC_Positions.positions_db
@onready var pc_positions: Dictionary = P5_Seq2_PC_Positions.positions_db
@onready var cast_bar : CastBar = get_tree().get_first_node_in_group("cast_bar")
@onready var enemy_cast_bar : EnemyCastBar = get_tree().get_first_node_in_group("enemy_cast_bar")
@onready var fail_list : FailList = get_tree().get_first_node_in_group("fail_list")
@onready var enemies_layer: Node3D = get_tree().get_first_node_in_group("enemies_layer")
@onready var doom_keys := ["doom1", "doom2", "doom3", "doom4", "free1", "free2", "free3", "free4"]

var thordan_model: Node3D
var party : Dictionary
var party_lineup : Dictionary
var party_lineup_keys : Array
var party_doom : Dictionary
var party_ps2 : Dictionary
var rtd_pc_positions : Dictionary
var rtd_npc_positions : Dictionary
var cleanse_puddles : Array
var twister_snapshots : Array
var tethers : Array
var divebomb_pos : Vector2
var eye_rotation : float
var thor_rotation : float
var arena_rotation := 0.0
var player: Player
var doom_anchor : bool
var tri_sqr_dooms : Array
var no_dooms: Array


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	initialize_party(new_party)
	# Pre-load resources.
	lockon_controller.pre_load([LockonController.PS_SQUARE, LockonController.PS_CIRCLE,
		LockonController.PS_CROSS, LockonController.PS_TRIANGLE, LockonController.DOOM])
	# Get strat variables
	var saved_index: int = SavedVariables.get_encounter_data("p5", "dooms")
	#if saved_index == SavedVariables.dooms.DEFAULT:
		#saved_index = SavedVariables.get_default("p5", "dooms")
	doom_anchor = saved_index == DsrSavedVariables.dooms.ANCHOR
	# Start timed sequence.
	death_anim_seq.play("death_sequence")


func reset_sequence() -> void:
	death_anim_seq.stop()
	cast_bar.clear_casts()
	enemy_cast_bar.clear_casts()
	# Set npcs to default position and visibility
	for key: String in npcs:
		if is_instance_valid(npcs[key]["node"]):
			npcs[key]["node"].queue_free()
	ground_aoe_controller.clear_all()
	fail_list.clear_list()
	party = {}
	cleanse_puddles = []
	twister_snapshots = []
	tethers = []


# Shuffles new party and stores it in Dictionary.
func initialize_party(new_party: Dictionary) -> void:
	party_lineup_keys = DsrSavedVariables.save_data["p5"]["lineup"]
	var party_list : Array = new_party.values()
	# Fill party list
	for i in Global.ROLE_KEYS.size():
		party[Global.ROLE_KEYS[i]] = party_list[i]
	# Fill lineup list
	for i in party_list.size():
		party_lineup[str(i)] = party[party_lineup_keys[i]]
	# Pick dooms and sort lineups. Rare pattern is 4/4 split.
	randomize()
	if DsrGlobal.rare_death_pattern:
		if randi() % 2 == 0:
			doom_keys = ["free1", "free2", "free3", "free4", "doom1", "doom2", "doom3", "doom4"]
	else:
		doom_keys.shuffle()
	var sorted_lineup_doom := []
	var sorted_lineup_free := []
	for i in party_lineup.size():
		var pc: PlayableCharacter = party_lineup[str(i)]
		if doom_keys[i].contains("doom"):
			sorted_lineup_doom.append(pc)
		else: 
			sorted_lineup_free.append(pc)
	# Populate doom party Dictionary in left>right order
	for i in sorted_lineup_doom.size():
		party_doom["doom%d" % (i + 1)] = sorted_lineup_doom[i]
	for i in sorted_lineup_free.size():
		party_doom["free%d" % (i + 1)] = sorted_lineup_free[i]
	no_dooms = sorted_lineup_free.duplicate()
	no_dooms.shuffle()
	# Instantiate starting NPCs
	npcs["thor"]["node"] = thordan_scene.instantiate()
	enemies_layer.add_child(npcs["thor"]["node"])
	thordan_model = npcs["thor"]["node"].get_node("ThordanModel")


# Called just before PS Markers are put up.
func assign_ps2() -> void:
	var circle_index := get_farthest_dooms()
	var tri_sqr_doom_index := [0, 1, 2, 3]
	tri_sqr_doom_index.erase(circle_index[0])
	tri_sqr_doom_index.erase(circle_index[1])
	tri_sqr_dooms = [party_doom["doom%d" % (tri_sqr_doom_index[0] + 1)],
		party_doom["doom%d" % (tri_sqr_doom_index[1] + 1)]]
	tri_sqr_dooms.shuffle()
	party_ps2 = {
		"cross1": no_dooms[0],
		"cross2": no_dooms[1],
		"circle1": party_doom["doom%d" % (circle_index[0] + 1)],
		"circle2": party_doom["doom%d" % (circle_index[1] + 1)],
		"triangle1" : no_dooms[2],
		"triangle2" : tri_sqr_dooms[0],
		"square1" : no_dooms[3],
		"square2" : tri_sqr_dooms[1]
	}
	# Make ps markers visible
	toggle_ps2_on()


# Returns the doom index (1-4) of the two doom farthest away from eachother.
# The first index returned is the one closest to the r-east doom bait spot.
func get_farthest_dooms() -> Array:
	var farthest_dist := 0.0
	var index_a := -1
	var index_b := -1
	for i in 3:
		for j in 4:
			if i == j:
				continue
			var dist: float = party_doom["doom%d" % (i + 1)].global_position.distance_squared_to(
				party_doom["doom%d" % (j + 1)].global_position)
			if dist > farthest_dist or farthest_dist == 0.0:
				farthest_dist = dist
				index_a = i
				index_b = j
	# Check which doom is closer to r-east safe spot. Swap it to index_a.
	var a_dist: float = v2(party_doom["doom%d" % (index_a + 1)].global_position).distance_squared_to(
		rtd_pc_positions["other"]["east_bait"])
	var b_dist: float = v2(party_doom["doom%d" % (index_b + 1)].global_position).distance_squared_to(
		rtd_pc_positions["other"]["east_bait"])
	if a_dist > b_dist:
		var temp := index_a
		index_a = index_b
		index_b = temp
	return [index_a, index_b]


func load_npcs_threaded() -> void:
	for key: String in npcs:
		if key == "thor":
			continue
		ResourceLoader.load_threaded_request(npcs[key]["path"], "PackedScene")


func instantiate_npcs() -> void:
	for key: String in npcs:
		if key == "thor":
			continue
		var npc_scene: PackedScene = ResourceLoader.load_threaded_get(npcs[key]["path"])
		var new_npc: Enemy = npc_scene.instantiate()
		new_npc.visible = false
		new_npc.scale = Vector3.ONE * npcs[key]["scale"]
		enemies_layer.add_child(new_npc)
		npcs[key]["node"] = new_npc


## Start of timed sequence.

## 12:50
# Cast DOTH (3.5s)
func cast_death() -> void:
	cast_bar.cast("Death of the Heavens", 3.5)
	load_npcs_threaded()


## 12:53.5
# Begin jump animation
func jump_thordan() -> void:
	thordan_model.start_jump()
	instantiate_npcs()
	randomize_positions()


## 12:58
# Thordan despawn, adds appear
func spawn_npcs() -> void:
	# Move NPCs
	for key: String in npcs:
		npcs[key]["node"].move_enemy(rtd_npc_positions[key])
		if key != "grin":
			npcs[key]["node"].look_at(Vector3.ZERO)
	# Show knights + dragon
	npcs["guer"]["node"].visible = true
	npcs["ign"]["node"].visible = true
	npcs["vido"]["node"].visible = true
	npcs["vedr"]["node"].visible = true
	npcs["thor"]["node"].visible = true
	npcs["dark"]["node"].visible = true


## 12:59
# Move bots to lineup
func move_to_lineup() -> void:
	for key: String in party_lineup:
		var pc : PlayableCharacter = party_lineup[key]
		#if pc.is_player():
			#continue
		pc.move_to(rtd_pc_positions["lineup"][key])

## 13:02
# Dooms appear (26s)
func spawn_dooms() -> void:
	var doom_dkeys := ["doom1", "doom2", "doom3", "doom4"]
	for key: String in doom_dkeys:
		var pc : PlayableCharacter = party_doom[key]
		var doom_timeout := pc.add_debuff(doom_icon_scene, 26.0)
		lockon_controller.add_marker(LockonController.DOOM, pc)
		doom_timeout.connect(on_doom_timeout)

## 13:03
# Move to lineup
func move_to_doom_lineup() -> void:
	for key: String in party_doom:
		var pc : PlayableCharacter = party_doom[key]
		#if pc.is_player():
			#continue
		pc.move_to(rtd_pc_positions["doom_lineup"][key])

## 13:03.5
# Heavy Impact telegraph appear
func impact_telegraph() -> void:
	ground_aoe_controller.spawn_circle(v2(npcs["guer"]["node"].global_position), IMPACT_1_RADIUS,
	5.5, Color.ORANGE, [0, 99, "Heavy Impact (Wave)"])

## 13:05.5
func move_to_impact_1() -> void:
	# Move to first positions
	for key: String in party_doom:
		var pc : PlayableCharacter = party_doom[key]
		#if pc.is_player():
			#continue
		pc.move_to(rtd_pc_positions["impact_1"][key])
	# Start enemy casts (only showing 3, missing Spear, Wings and Heavy) (6s)
	enemy_cast_bar.start_cast_bar_1("Twisting Dive", 5.5)
	enemy_cast_bar.start_cast_bar_2("Lightning Storm", 5.5)
	enemy_cast_bar.start_cast_bar_3("Cauterize", 5.5)

## 13:09
# First Impact hit
func impact_1() -> void:
	ground_aoe_controller.spawn_circle(v2(npcs["guer"]["node"].global_position), IMPACT_1_RADIUS,
		0.4, Color.RED, [0, 0, "Heavy Impact (Wave)"])

## 13:10.5
# Start divebome anims
func start_dive_anim() -> void:
	npcs["vedr"]["node"].play_divebomb()
	npcs["dark"]["node"].play_divebomb()
	npcs["dark"]["node"].move_toward_center()

## 13:11
# Lightning, divebombs, 2nd Impact, Cleanse puddles, Spawn eye
func impact_2() -> void:
	# Spawn Line AoE's
	ground_aoe_controller.spawn_line(v2(npcs["ign"]["node"].global_position), SIDE_DIVEBOMB_WIDTH,
		SIDE_DIVEBOMB_LENGTH, Vector2(0, 0), 0.3, Color.ORANGE_RED, [0, 0, "Spear of the Fury (Line)"])
	ground_aoe_controller.spawn_line(v2(npcs["vedr"]["node"].global_position), SIDE_DIVEBOMB_WIDTH,
		SIDE_DIVEBOMB_LENGTH, Vector2(0, 0), 0.3, Color.ORANGE_RED, [0, 0, "Twisting Dive (Line)"])
	ground_aoe_controller.spawn_line(v2(npcs["dark"]["node"].global_position), CENTER_DIVEBOMB_WIDTH,
		CENTER_DIVEBOMB_LENGTH, Vector2(0, 0), 0.3, Color.REBECCA_PURPLE, [0, 0, "Cauterize (Line)"])
	# Spawn lightnings and cleanse puddles
	for key: String in party_doom:
		var pc: PlayableCharacter = party_doom[key]
		ground_aoe_controller.spawn_circle(v2(pc.global_position), CLEANSE_PUDDLE_GROW_RADIUS,
			0.3, Color.PURPLE, [0, 1, "Lightning", [pc]])
		if key.contains("free"):
			var puddle := ground_aoe_controller.spawn_circle(v2(pc.global_position), CLEANSE_PUDDLE_GROW_RADIUS,
			CLEANSE_PUDDLE_DURATION, Color.LIGHT_BLUE, [0, 99, "[Debug]Cleanse Puddle"])
			cleanse_puddles.append(puddle)
	# Show eye
	npcs["eye"]["node"].visible = true
	# 2nd Impact
	ground_aoe_controller.spawn_donut(v2(npcs["guer"]["node"].global_position), IMPACT_1_RADIUS,
		IMPACT_2_RADIUS, 0.4, Color.RED, [0, 0, "Heavy Impact (Wave)"])
	# Hide/show knights
	npcs["guer"]["node"].visible = false
	npcs["nod"]["node"].visible = true
	npcs["char"]["node"].visible = true
	npcs["grin"]["node"].visible = true


## 13:11.5
func twister_snapshot() -> void:
	# Twister snapshot
	for key: String in party:
		twister_snapshots.append(v2(party[key].global_position))
	# Move to second positions
	for key: String in party_doom:
		var pc : PlayableCharacter = party_doom[key]
		#if pc.is_player():
			#continue
		pc.move_to(rtd_pc_positions["impact_2"][key])


## 13:13
func impact_3() -> void:
	# Spawn twisters
	for twister_pos: Vector2 in twister_snapshots:
		ground_aoe_controller.spawn_twister(twister_pos, 4.0, [0, 0, "Twister"])
	# Impact 3
	ground_aoe_controller.spawn_donut(v2(npcs["guer"]["node"].global_position), IMPACT_2_RADIUS,
			IMPACT_3_RADIUS, 0.4, Color.RED, [0, 0, "Heavy Impact (Wave)"])
	npcs["ign"]["node"].visible = false


## 13:13.5
# Move to impact position 3
func move_to_impact_3() -> void:
	for key: String in party_doom:
		var pc : PlayableCharacter = party_doom[key]
		#if pc.is_player():
			#continue
		pc.move_to(rtd_pc_positions["impact_3"][key])

## 13:15
# Forth Impact
func impact_4() -> void:
	ground_aoe_controller.spawn_donut(v2(npcs["guer"]["node"].global_position), IMPACT_3_RADIUS,
			IMPACT_4_RADIUS, 0.4, Color.RED, [0, 0, "Heavy Impact (Wave)"])

## 13:17
# Fifth Impact
func impact_5() -> void:
	ground_aoe_controller.spawn_donut(v2(npcs["guer"]["node"].global_position), IMPACT_4_RADIUS,
			IMPACT_5_RADIUS, 0.4, Color.RED, [0, 0, "Heavy Impact (Wave)"])

## 13:19
func show_ps_markers() -> void:
	# PS markers appear
	assign_ps2()
	# Cast dragon gaze(4s)+heavensflame
	npcs["thor"]["node"].toggle_gaze()
	enemy_cast_bar.start_cast_bar_1("The Dragon's Gaze", 5.0)
	enemy_cast_bar.start_cast_bar_2("Heavensflame", 6.5)


## 13.21.5
# Move to ps2 positions
# Purposely delayed to not make it obvious to player where to go.
func move_to_ps2() -> void:
	if doom_anchor:
		move_to_doom_anchor_pos()
	else:
		move_to_static_pos()
	# Shrink puddles
	for puddle: CircleAoe in cleanse_puddles:
		puddle.set_radius(CLEANSE_PUDDLE_RADIUS)
		puddle.circle_body_entered.connect(on_cleanse_puddle_entered)


# TODO: clean this up (add 2 positions for SE/SW triangle)
func move_to_doom_anchor_pos() -> void:
	# Move cross and circles (static)
	party_ps2["cross1"].move_to(rtd_pc_positions["ps2_anchor"]["cross1"])
	party_ps2["cross2"].move_to(rtd_pc_positions["ps2_anchor"]["cross2"])
	party_ps2["circle1"].move_to(rtd_pc_positions["ps2_anchor"]["circle1"])
	party_ps2["circle2"].move_to(rtd_pc_positions["ps2_anchor"]["circle2"])
	# Move flex non-dooms
	var triangle_sw : bool = party_ps2["triangle2"] == party_doom["doom2"]
	#print("trisw:", triangle_sw)
	if triangle_sw:
		party_ps2["triangle1"].move_to(rtd_pc_positions["ps2_anchor"]["flex2"])
		party_ps2["triangle2"].move_to(rtd_pc_positions["ps2_anchor"]["doom2"])
		party_ps2["square1"].move_to(rtd_pc_positions["ps2_anchor"]["flex3"])
		party_ps2["square2"].move_to(rtd_pc_positions["ps2_anchor"]["doom3"])
	else:
		party_ps2["triangle1"].move_to(rtd_pc_positions["ps2_anchor"]["flex3"])
		party_ps2["triangle2"].move_to(rtd_pc_positions["ps2_anchor"]["doom3"])
		party_ps2["square1"].move_to(rtd_pc_positions["ps2_anchor"]["flex2"])
		party_ps2["square2"].move_to(rtd_pc_positions["ps2_anchor"]["doom2"])


func move_to_static_pos() -> void:
	for key: String in party_ps2:
		var pc : PlayableCharacter = party_ps2[key]
		#if pc.is_player():
			#continue
		pc.move_to(rtd_pc_positions["ps2"][key])
	


## 13:23
# Add chains debuffs (15s), check proximity to middle
func add_chains() -> void:
	for key: String in party_ps2:
		var pc : PlayableCharacter = party_ps2[key]
		pc.add_debuff(chains_icon_scene, 2.0)
		# Check if player is too far from middle (fails mechanic)
		if pc.is_player() and pc.global_position.distance_squared_to(Vector3.ZERO) > (CHAINS_MIN_SNAP_DIST ** 2):
			fail_list.add_fail("Player was too far for chain snapshot.")
	# Spawn tethers
	spawn_tether(party_ps2["cross1"], party_ps2["cross2"])
	spawn_tether(party_ps2["triangle1"], party_ps2["triangle2"])
	spawn_tether(party_ps2["circle1"], party_ps2["circle2"])
	spawn_tether(party_ps2["square1"], party_ps2["square2"])
	# Remove ps2
	toggle_ps2_off()


## 13:24
# Check facing angle of player
# Knockback from middle
func knockback() -> void:
	for key: String in party_ps2:
		var pc : PlayableCharacter = party_ps2[key]
		# Check if player is facing eye or thordan
		if pc.is_player() and !Global.spectate_mode:
			check_gaze(pc)
		# Knockback from middle
		pc.knockback(KNOCKBACK_DIST, Vector2.ZERO)
	# Remove gaze telegraph from Thordan
	npcs["thor"]["node"].toggle_gaze()


## 13.24.75
# Check tethers. 
# TODO: create a more responsive tether controller.
func check_tethers() -> void:
	for tether: Tether in tethers:
		if tether.get_dist_to_target() < TETHER_BREAK_DIST:
			fail_list.add_fail("Tether did not break.")
		else:
			tether.queue_free()
	for key: String in party:
		party[key].remove_debuff("chains")

## 13.25
# Move to doom cleanse
func move_to_cleanse() -> void:
	if doom_anchor:
		# TODO: add doom anchor positions
		return
	for key: String in party_ps2:
		var pc : PlayableCharacter = party_ps2[key]
		#if pc.is_player():
			#continue
		pc.move_to(rtd_pc_positions["post_kb"][key])

## 13:25.5
# Spawn hellflame aoe's
func spawn_hellflame() -> void:
	for key: String in party_ps2:
		var pc : PlayableCharacter = party_ps2[key]
		ground_aoe_controller.spawn_circle(v2(pc.global_position),
			HELLFLAME_RADIUS, 0.3, Color.RED, [0, 1, "Hellflame", [pc]])


## Utility methods

func check_gaze(pc : PlayableCharacter) -> void:
	# Syncs player model rotation to angle_to_point vector (x-axis)
	var player_rotation := fposmod((rad_to_deg(pc.get_model_rotation().y) + 180), 360.0)
	var angle_to_thordan := fposmod(rad_to_deg(v2(pc.global_position).angle_to_point(
		v2(npcs["thor"]["node"].global_position))) * -1 + 90, 360.0)
	var angle_to_eye := fposmod(rad_to_deg(v2(pc.global_position).angle_to_point(
		v2(npcs["eye"]["node"].global_position))) * -1 + 90, 360.0)
	# Check Thordan
	if angle_to_thordan < 45:
		if player_rotation < angle_to_thordan + 45 or player_rotation > 315 + angle_to_thordan:
			fail_list.add_fail("Player looked at Thordan Gaze.")
	elif angle_to_thordan > 315:
		if player_rotation > angle_to_thordan - 45 or player_rotation < angle_to_thordan - 315:
			fail_list.add_fail("Player looked at Thordan Gaze.")
	elif player_rotation > angle_to_thordan - 45 and player_rotation < angle_to_thordan + 45:
		fail_list.add_fail("Player looked at Thordan Gaze.")
	# Check Eye
	elif angle_to_eye < 45:
		if player_rotation < angle_to_eye + 45 or player_rotation > 315 + angle_to_eye:
			fail_list.add_fail("Player looked at Eye Gaze.")
	elif angle_to_eye > 315:
		if player_rotation > angle_to_eye - 45 or player_rotation < angle_to_eye - 315:
			fail_list.add_fail("Player looked at Eye Gaze.")
	elif player_rotation > angle_to_eye - 45 and player_rotation < angle_to_eye + 45:
		fail_list.add_fail("Player looked at Eye Gaze.")


func toggle_ps2_on() -> void:
	for key: String in party_ps2:
		if key.contains("square"):
			lockon_controller.add_marker(LockonController.PS_SQUARE, party_ps2[key])
		elif key.contains("cross"):
			lockon_controller.add_marker(LockonController.PS_CROSS, party_ps2[key])
		elif key.contains("triangle"):
			lockon_controller.add_marker(LockonController.PS_TRIANGLE, party_ps2[key])
		else:
			lockon_controller.add_marker(LockonController.PS_CIRCLE, party_ps2[key])


func toggle_ps2_off() -> void:
	for key: String in party_ps2:
		if key.contains("square"):
			lockon_controller.remove_marker(LockonController.PS_SQUARE, party_ps2[key])
		elif key.contains("cross"):
			lockon_controller.remove_marker(LockonController.PS_CROSS, party_ps2[key])
		elif key.contains("triangle"):
			lockon_controller.remove_marker(LockonController.PS_TRIANGLE, party_ps2[key])
		else:
			lockon_controller.remove_marker(LockonController.PS_CIRCLE, party_ps2[key])


# Handles doom timer timeout
func on_doom_timeout(owner_key: String) -> void:
	var pc: PlayableCharacter = party[owner_key]
	if pc.is_player() and !Global.spectate_mode:
		fail_list.add_fail("Player failed to cleanse Doom.")
	#remove_debuff("doom")
	#lockon_controller.remove_marker(LockonController.DOOM, pc)


func spawn_tether(source: Node3D, target: Node3D) -> void:
	var tether : Tether = tether_scene.instantiate()
	source.add_child(tether)
	tether.set_target(target)
	tether.active = true
	tethers.append(tether)


# Called when a body enters puddle
func on_cleanse_puddle_entered(body: CharacterBody3D, puddle: CircleAoe) -> void:
	if party_doom.find_key(body).contains("doom"):
		body.remove_debuff("doom")
		lockon_controller.remove_marker(LockonController.DOOM, body)
	puddle.queue_free()


# Randomizes the variable npc spawn positions, rotates the position dictionary
func randomize_positions() -> void:
	arena_rotation = 90.0 * randi_range(0, 3)
	# Copy to new dictionary with rotated vectors
	rtd_pc_positions = pc_positions.duplicate(true)
	rtd_npc_positions = npc_positions.duplicate(true)
	# Variant NPC positions
	# Darkscale
	if randi_range(0, 1) == 0:
		rtd_npc_positions["dark"] = rtd_npc_positions["dark"].rotated(deg_to_rad(180))
	# Eye/Thordan
	eye_rotation = 45.0 * randi_range(0, 7)
	thor_rotation = 45.0 * randi_range(-1, 1)
	rtd_npc_positions["eye"] = rtd_npc_positions["eye"].rotated(deg_to_rad(eye_rotation))
	rtd_npc_positions["thor"] = rtd_npc_positions["thor"].rotated(deg_to_rad(eye_rotation + thor_rotation))
	
	# Vedr/Ign/Vido
	if randi_range(0, 1) == 0:
		# Flip E/W
		rtd_npc_positions["vedr"] = rtd_npc_positions["vedr"].rotated(deg_to_rad(180))
		rtd_npc_positions["ign"] = rtd_npc_positions["ign"].rotated(deg_to_rad(180))
		rtd_npc_positions["vido"] = rtd_npc_positions["vido"].rotated(deg_to_rad(180))
	if randi_range(0, 1) == 0:
		# Flip Vedr/Ign
		var temp_pos: Vector2 = rtd_npc_positions["vedr"]
		rtd_npc_positions["vedr"] = rtd_npc_positions["ign"]
		rtd_npc_positions["ign"] = temp_pos
	# Rotate arena
	if arena_rotation == 0.0:
		return
	for pos_key: String in pc_positions:
		for pc_key: String in pc_positions[pos_key]:
			rtd_pc_positions[pos_key][pc_key] = rotate_pos(rtd_pc_positions[pos_key][pc_key])
	for npc_key: String in npc_positions:
		rtd_npc_positions[npc_key] = rotate_pos(rtd_npc_positions[npc_key])


# Rotates the vector by a multiple of 90 deg
func rotate_pos(pos : Vector2) -> Vector2:
	return pos.rotated(deg_to_rad(arena_rotation))


# Converts Vector3(x,z) -> Vectors2
func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
