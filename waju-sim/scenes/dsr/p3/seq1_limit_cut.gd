# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Handles all timings and behaviour for Limit Cut sequence.

extends Node

enum arrow {RANDOM, UP, CIRCLE, DOWN}

# Spell Dimensions
const TOWER_DROP_RADIUS := 10.0
const PARTY_SOAK_RADIUS := 10.0
const TOWER_SOAK_RADIUS := 10.0
const LASH_INNER_RADIUS := 15.8
const LASH_OUTTER_RADIUS := 60.0
const GNASH_RADIUS := 15.8
const GEIR_WIDTH := 15.0
const GEIR_LENGTH := 60.0
const ARROW_LENGTH := 30.0
const CLONE_ROTATION_SPEED := 0.5

@export var icon_scenes: Array[PackedScene]
@export var clone_scene: PackedScene

@onready var icon_scene_dict := {"up": icon_scenes[0], "circle": icon_scenes[1],
	"down": icon_scenes[2], "lc1": icon_scenes[3],
	"lc2": icon_scenes[4], "lc3": icon_scenes[5]}
@onready var cast_bar: CastBar = get_tree().get_first_node_in_group("cast_bar")
@onready var clone_cast_bar: CloneCastBar = get_tree().get_first_node_in_group("clone_cast_bar")
@onready var fail_list: FailList = get_tree().get_first_node_in_group("fail_list")
@onready var enemies_layer: Node = get_tree().get_first_node_in_group("enemies_layer")
@onready var ground_aoe_controller : GroundAoeController = %GroundAoEController
@onready var animation_player: AnimationPlayer = %LimitCutSeq
@onready var lockon_controller: LockonController = %LockonController
@onready var nidhogg: Nidhogg = %Nidhogg

var lockon_ids := {"lc1": LockonController.LC_1, "lc2": LockonController.LC_2, "lc3": LockonController.LC_3}
var has_arrows := {"lc1": false, "lc2": false, "lc3": false}
var arrow_durations := {"lc1": 9.1, "lc2": 19.1, "lc3": 30.1}
var lc_key_str := ["rand", "lc1", "lc2", "lc3"]
var player: Player
var player_lc: int
var player_arrow : int
var forced_arrow := 0
var positions: Dictionary
var tower_snapshots : Dictionary
var towers : Dictionary
var clones : Dictionary
var party : Dictionary
var lash_first := false
var hide_lc_markers := true
var strat : int


func start_sequence(new_party: Dictionary) -> void:
	load_settings()
	assert(new_party != null, "Error. Where the party at?")
	initialize_party(new_party)
	# Pre-load resources.
	ground_aoe_controller.preload_aoe(["circle", "donut", "line", "tower"])
	lockon_controller.pre_load([LockonController.LC_1,
		LockonController.LC_2, LockonController.LC_3])
	# Start timed sequence.
	print("Starting Limit Cut.")
	animation_player.play("limit_cut_sequence")


func load_settings() -> void:
	# East/Westhogg
	strat = DsrSavedVariables.get_data("p3", "nidhogg")
	match strat:
		DsrSavedVariables.nidhogg.WEST:
			positions = P3S1_Positions.positions_db
		DsrSavedVariables.nidhogg.EAST:
			positions = P3S1_Positions_East.positions_db
		_:
			print("Error: Invalid strategy string in config. Loading Westhogg.")
			positions = P3S1_Positions.positions_db
	# LC Assignment
	player_arrow = DsrGlobal.p3_arrow  # 0 = rand
	player_lc = DsrGlobal.p3_in_line   # 0 = rand


# Shuffles new party and stores it in Dictionary.
func initialize_party(new_party: Dictionary) -> void:
	player = get_tree().get_first_node_in_group("player")
	var party_list := new_party.values()
	randomize()
	party_list.shuffle()
	# Handle determined player assignment.
	if not (player_arrow == 0 and player_lc == 0):
		# Randomize if needed
		if player_lc == 0:
			player_lc = randi_range(1, 3)
		if player_arrow == 0:
			player_arrow = randi_range(1, 3) if player_lc != 2 else randi_range(1, 2)
		# If not random arrow, force LC to have arrows.
		else:
			forced_arrow = player_lc
		var player_index := 0
		# Determine LC starting index
		if player_lc != 1:
			player_index += 3 if player_lc == 2 else 5
		# Add from arrow index
		# Handle LC2 Down arrow selection.
		if player_lc == 2 and player_arrow == 3:
			player_arrow = 2
		player_index += (player_arrow - 1)
		# Swap party list
		var index_to_swap := party_list.find(player)
		var temp: PlayableCharacter = party_list[player_index]
		party_list[player_index] = party_list[index_to_swap]
		party_list[index_to_swap] = temp
	# Convert to dictionary
	party = {
		"lc1": {
			"up": party_list[0],
			"circle": party_list[1],
			"down": party_list[2]
		},
		"lc2": {
			"up": party_list[3],
			"down": party_list[4]
		},
		"lc3": {
			"up": party_list[5],
			"circle": party_list[6],
			"down": party_list[7]
		}
	}


## Start of timed sequence.

## 0:02
func pre_spread_pos() -> void:
	move_bots("pre_spread")


## 6.00
# Assign all players an LC number, this has no bearing on which E/S/W spot they go to
func assign_lc() -> void:
	cast_bar.cast("Dive from Grace", 5.4)
	for lc_key: String in party:
		for pos_key: String in party[lc_key]:
			var pc: PlayableCharacter = party[lc_key][pos_key]
			lockon_controller.add_marker(lockon_ids[lc_key], pc)
			#pc.get_node("Lockon/%s" % lc_key.to_upper()).visible = true
			# Set icons
			pc.add_debuff(icon_scene_dict[lc_key])

## 0:07
# Move party to nearest LC positions, adjust assignments
func lc_pre_pos() -> void:
	var valid_positions: Dictionary = positions["lc_setup"].duplicate(true)
	var unassigned_party := party.duplicate(true)
	# Each loop assigns the one nearest player to a valid position from each LC#.
	for i in 3:
		for lc_key: String in unassigned_party:
			var nearest_data := get_nearest_char_and_pos(unassigned_party[lc_key], valid_positions[lc_key])
			if nearest_data == {}:  # No characters in party
				continue
			var nearest_char : CharacterBody3D = unassigned_party[lc_key][nearest_data["pt_key"]]
			# Update dicts
			unassigned_party[lc_key].erase(nearest_data["pt_key"])
			valid_positions[lc_key].erase(nearest_data["pos_key"])
			party[lc_key][nearest_data["pt_key"]] = nearest_char
	move_bots("lc_setup")

## 11.40
# Randomly assign arrows to LC groups, shuffles the arrow groups and send debuffs
func assign_arrows() -> void:
	for pt_key: String in party:
		if pt_key == lc_key_str[forced_arrow]:
			has_arrows[pt_key] = true
			continue
		has_arrows[pt_key] = randi() % 2 == 0
		if has_arrows[pt_key]:
			shuffle_dict(party[pt_key])
	set_arrow_debuffs()

# Sends debuff data to player and bots to be displayed.
func set_arrow_debuffs() -> void:
	for lc_key: String in party:
		for pos_key: String in party[lc_key]:
			var pc: PlayableCharacter = party[lc_key][pos_key]
			if has_arrows[lc_key]:
				pc.add_debuff(icon_scene_dict[pos_key], arrow_durations[lc_key])
			else: # Assign High Jump to all
				pc.add_debuff(icon_scene_dict["circle"], arrow_durations[lc_key])
			# Remove LC marker.
			if hide_lc_markers:
				lockon_controller.remove_marker(lockon_ids[lc_key], pc)


## 13.10
func cast_lg() -> void:
	lash_first = randi() % 2 == 0
	cast_bar.cast("Lash and Gnash" if lash_first else "Gnash and Lash", 7.3)
	nidhogg.start_lg()


## 15.0
# Tower 1 Drop positions
func tower1_pos1() -> void:
	move_bots("t1_p1")
	if has_arrows["lc1"]:
		party["lc1"]["down"].set_look_direction(positions["west"])

## 0:21.1
# Spawn Tower_AoE_1 on 1's (check for double hit), record positions /w arrows
# Spawn Group Soak 1 AoE on random 2/3 (check for 5 hits)
func tower1_hit() -> void:
	tower_hit("lc1")
	# Spawn group soak on random 2/3
	var pc := pick_rand_character(["lc2", "lc3"])
	ground_aoe_controller.spawn_circle(v2(pc.global_position), PARTY_SOAK_RADIUS, 0.3,
		Color.ORANGE_RED, [5, 5, "Eye of the Tyrant (group soak)"])

# Drops tower AoE's on give LC group. Remove LC1 debuffs.
func tower_hit(lc_key: String) -> void:
	tower_snapshots.clear()
	for pos_key: String in party[lc_key]:
		var pc: PlayableCharacter = party[lc_key][pos_key]
		ground_aoe_controller.spawn_circle(v2(pc.global_position), TOWER_DROP_RADIUS,
			0.3, Color.RED, [0, 1, "Tower Drop", [pc]])
		pc.remove_debuff(lc_key)
		if has_arrows[lc_key] and pos_key != "circle":
			tower_snapshots[pos_key] = v2(pc.get_arrow_vector(ARROW_LENGTH, pos_key))
		else:
			tower_snapshots[pos_key] = v2(pc.global_position)

## 0:21.5
# Move to Tower 1 Soak positions (In or Out)
func tower1_pos2() -> void:
	# Reset lc1 up look position to boss
	if has_arrows["lc1"]:
		party["lc1"]["down"].set_look_direction(Vector3.ZERO)
	if lash_first:
		move_bots("t1_p2_in")
	else:
		move_bots("t1_p2_out")


## 24.6
# Spawn In/Out AoE (check for any hit)
# Spawn Tower_Soaks_1 on recorded positions
func tower1_lg1_hit() -> void:
	spawn_lash_gnash(1)
	tower_soak_spawn()


func spawn_lash_gnash(hit: int) -> void:
	# Lash
	if (lash_first && hit == 1) or (!lash_first && hit == 2) :
		ground_aoe_controller.spawn_donut(Vector2.ZERO, LASH_INNER_RADIUS,
			LASH_OUTTER_RADIUS, .4, Color.WEB_PURPLE, [0, 0, "Lash (Dynamo)"])
	# Gnash
	else:
		ground_aoe_controller.spawn_circle(Vector2.ZERO, GNASH_RADIUS, .4,
			Color.WEB_PURPLE, [0, 0, "Gnash (Charriot)"])


func tower_soak_spawn() -> void:
	towers.clear()
	for pos_key: String in tower_snapshots:
		var tower: TowerAoe = ground_aoe_controller.spawn_tower(
			tower_snapshots[pos_key], TOWER_SOAK_RADIUS, 2.2, Color.DARK_ORANGE)
		towers[pos_key] = tower


## 0:25.5
# Move to Soak_1_Pos_2 (In or Out) - (if out, 2's go out)
func tower1_pos3() -> void:
	if lash_first:
		move_bots("t1_p3_out")
	else:
		move_bots("t1_p3_in")

## 0:27.4
# Check tower soaks, spawn clones, lockon to nearest
func tower1_soak_hit() -> void:
	# Check Towers
	tower_soak_clone_spawn()


func tower_soak_clone_spawn() -> void:
	clones.clear()
	for key: String in towers:
		var tower: TowerAoe = towers[key]
		var bodies := tower.get_collisions()
		check_fail(bodies, 1, 1, "Tower Soak (%s)." % key)  # TODO Add whitelist with flipped key on arrows.
		# Spawn clone
		var clone := clone_scene.instantiate() as Nidhogg
		enemies_layer.add_child(clone)
		clone.global_position = tower.global_position
		#clone.play_dive_animation()
		clones[key] = clone

## 27.6
func spawn_lg_2() -> void:
	spawn_lash_gnash(2)


## 28.0
# Move to clone bait positions (2's out)
func tower2_pos1() -> void:
	move_bots("t2_p1")
	if has_arrows["lc2"]:
		party["lc2"]["up"].set_look_direction(positions["t2_west"])
		party["lc2"]["down"].set_look_direction(positions["t2_west"])

## 28.8
# Set lockon for clones
# Spawn In/Out AoE (check for any hit)
func tower1_lg2_hit() -> void:
	clones_lockon()

# Set clones lockon nearest player
func clones_lockon() -> void:
	for key: String in clones:
		var clone: Nidhogg = clones[key]
		var nearest := get_nearest_player_to_vector(clone.global_position)
		clone.set_lockon(nearest)

## 30.0
# Start Geir Casts on locked pos (4.2s)
func tower1_geir_cast() -> void:
	start_geir_cast()

func start_geir_cast() -> void:
	clone_cast_bar.cast_clone("Geirskogul", 4.2)
	for key: String in clones:
		clones[key].remove_lockon()
		clones[key].start_geir()

## 30.8
# Spawn Tower_AoE_2 on 2's (check for double hit), record positions w/ arrows
func tower2_tower_hit() -> void:
	# Drop tower AoE's on 2's
	tower_snapshots.clear()
	tower_hit("lc2")

## 0:31.5
# Move to Dodge Geir positions (2's move in, 1's move out)
func tower2_pos2() -> void:
	move_bots("t2_p2")

## 0:34.2
# Spawn Geir 1 AoEs, check for hits
func tower1_geir_hit() -> void:
	spawn_geir_line_aoe()


func spawn_geir_line_aoe() -> void:
	for key: String in clones:
		var clone: Nidhogg = clones[key]
		var line_target := clone.get_facing_vector()
		ground_aoe_controller.spawn_line(v2(clone.global_position), GEIR_WIDTH,
			GEIR_LENGTH, v2(line_target), 0.3, Color.CORAL, [0, 0, "Geirskogul"])
		clone.finish_geir()

## 34.6
# Start Gnash/Lash 2 cast (7.3s)
# Spawn Tower_2 soaks on recorded positions w/ arrows
func tower2_soak_spawn() -> void:
	cast_lg()
	tower_soak_spawn()

## 37.7
# Check tower 2 soaks, spawn clones 2, lockon to nearest
func tower2_soak_hit() -> void:
	tower_soak_clone_spawn()

## 38.8
# Clones lock on target (if moving 1's out, do it here)
func tower2_pos3() -> void:
	clones_lockon()

## 40.0
# Start Geir Casts on locked pos (4.2s)
func tower2_geir_cast() -> void:
	start_geir_cast()

## 40.5
# Move to tower 3 drop pos (1's move in, 3's move to drop pos and turn down if needed)
func tower3_pos1() -> void:
	move_bots("t3_p1")
	if has_arrows["lc3"]:
		party["lc3"]["down"].set_look_direction(positions["west"])

## 42.1
# Spawn Tower_AoE_3 on 3's (check for double hit), record positions /w arrows
# Spawn Group Soak AoE on random 2/3 (check for 5 hits)
func tower3_tower_hit() -> void:
	tower_hit("lc3")
	# Spawn group soak on random 1/2
	var pc: PlayableCharacter = pick_rand_character(["lc1", "lc2"])
	ground_aoe_controller.spawn_circle(v2(pc.global_position), PARTY_SOAK_RADIUS,
		0.3, Color.ORANGE_RED, [5, 5, "Eye of the Tyrant (group soak)"])

## 0:42.6
# Move to soak 3 pos (2's/1 out, all dodge in/out)
func tower3_pos2() -> void:
	if lash_first:
		move_bots("t3_p2_in")
	else:
		move_bots("t3_p2_out")

## 44.2
# Spawn Geir 2 AoEs on locked pos, check for hits
func tower2_geir_hit() -> void:
	spawn_geir_line_aoe()

## 46.0
# Spawn In/Out AoE (check for any hit)
# Spawn Tower_Soaks_3 on recorded positions
func tower3_lg1_hit() -> void:
	spawn_lash_gnash(1)
	tower_soak_spawn()

## 46.8
# Move to Soak_3_Pos_2 (dodge In or Out)
func tower3_pos3() -> void:
	if lash_first:
		move_bots("t3_p2_out")
	else:
		move_bots("t3_p2_in")

## 48.6
# Check tower 3 soaks, spawn clones 3, lockon to nearest
func tower3_soak_hit() -> void:
	tower_soak_clone_spawn()
	#spawn_lash_gnash(2)

## 48.8 spawn lg2

## 49.5
# Move to clone 3 bait positions (3's move, rest stack NE/NW, ignoring tank pos)
func tower3_pos4() -> void:
	move_bots("t3_p2_out")

## 50.7
# Spawn In/Out 3-2 AoE (check for any hit)
func tower3_lg2_hit() -> void:
	clones_lockon()

## 51.0
# Start Geir 3 Casts on locked pos (4.2s)
func tower3_geir_cast() -> void:
	start_geir_cast()

## 0:52
# Move to Final positions (2s/1 dodge Geir)
func tower3_final_pos() -> void:
	move_bots("t3_p3")

## 0:55.2
# Spawn Geir 3 AoEs on locked pos, check for hits
func tower3_geir_hit() -> void:
	spawn_geir_line_aoe()

## End of Timed sequence


## Animation Sequence

## 11.0
func dfg_finish() -> void:
	nidhogg.finish_dfg()


## 20.4
func lg_finish(lc_key: String) -> void:
	if lc_key != "lc2":
		nidhogg.finish_lg()
	# Spawn quick dives.
	spawn_quick_dives(lc_key)


func spawn_quick_dives(lc_key: String) -> void:
	for pos_key: String in party[lc_key]:
		var bunny: Nidhogg = clone_scene.instantiate()
		bunny.set_start_position(party[lc_key][pos_key].global_position)
		bunny.set_role(2)
		enemies_layer.add_child(bunny)

## 24.4
func lg_hit(hit: int) -> void:
	if (lash_first && hit == 1) or (!lash_first && hit == 2) :
		nidhogg.lash_hit()
	else:
		nidhogg.gnash_hit()

## 27.4 lg_hit(2)

## Utility methods


# Moves bots to their assigned position at a given stage.
func move_bots(stg_key : String) -> void:
	for lc_key: String in party:
		for pos_key: String in party[lc_key]:
			var pc: PlayableCharacter = party[lc_key][pos_key]
			#if pc.is_player():
				#continue
			pc.move_to(positions[stg_key][lc_key][pos_key])


# Checks if given fail conditions are met and adds any fails to the fail_list UI element.
func check_fail(bodies: Array, min_hit := 0, max_hit := 99, spell_name := "",
	whitelist := [], blacklist := []) -> bool:
	# Too few hit fail condition
	if min_hit > 0 and bodies.size() < min_hit:
		fail_list.add_fail("Not enough targets hit by %s" % spell_name)
		return true
	var fail_bodies_list := []
	# Too many hit fail condition
	if max_hit < 99 and bodies.size() > max_hit:
		for body: CharacterBody3D in bodies:
			if whitelist.has(body):
				continue
			fail_bodies_list.append(body)
	# Blacklist fail condition
	if blacklist.size() > 0:
		for body: CharacterBody3D in bodies:
			if blacklist.has(body):
				fail_bodies_list.append(body)
	# Output fails
	if fail_bodies_list.size() == 1:
		fail_list.add_fail("%s was hit by %s" % [fail_bodies_list[0].name, spell_name])
		return true
	if fail_bodies_list.size() > 1:
		fail_list.add_fail("Multiple targets were hit by %s" % spell_name)
		return true
	# No fails smile
	return false


# Converts Vector3(x,z) -> Vectors2
func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)


# Picks a random character from the given LC groups
func pick_rand_character(lc_keys: Array[String]) -> CharacterBody3D:
	var valid_chars: Array[CharacterBody3D] = []
	for lc_key: String in lc_keys:
		for pos_key: String in party[lc_key]:
			valid_chars.append(party[lc_key][pos_key])
	return valid_chars[randi_range(0, valid_chars.size() - 1)]


# Returns the party member closest to v3.
func get_nearest_player_to_vector(v3 : Vector3) -> CharacterBody3D:
	var nearest_char: CharacterBody3D
	var nearest_dist_sqrd := 0.0
	for lc_key: String in party:
		for pos_key: String in party[lc_key]:
			var pc: PlayableCharacter = party[lc_key][pos_key]
			var dist := pc.global_position.distance_squared_to(v3)
			if nearest_dist_sqrd == 0.0 or dist < nearest_dist_sqrd:
				nearest_char = pc
				nearest_dist_sqrd = dist
	return nearest_char


# Returns the char and pos keys for the character nearest to a valid position.
func get_nearest_char_and_pos(this_party: Dictionary, valid_positions: Dictionary) ->  Dictionary:
	if this_party.size() == 0:
		return {}
	var nearest_pt_key := ""
	var nearest_pos_key := ""
	var nearest_dist := 0.0
	for pt_key: String in this_party:
		var this_char: CharacterBody3D = this_party[pt_key]
		var dist_data := dist_to_nearest_position(this_char, valid_positions)
		if dist_data["dist"] < nearest_dist or nearest_pt_key == "" :
			nearest_pt_key = pt_key
			nearest_pos_key = dist_data["pos_key"]
			nearest_dist = dist_data["dist"]
	return {"pt_key": nearest_pt_key, "pos_key": nearest_pos_key}


# Returns the pos key and distance_sqr to the valid position nearest to the character.
func dist_to_nearest_position(character : CharacterBody3D, valid_positions: Dictionary) -> Dictionary:
	var nearest_key := ""
	var nearest_dist := 0.0
	for pos_key: String in valid_positions:
		var pos := Vector3(valid_positions[pos_key].x, 0, valid_positions[pos_key].y)
		var dist := character.global_position.distance_squared_to(pos)
		if nearest_key == "" or dist < nearest_dist:
			nearest_key = pos_key
			nearest_dist = dist
	return {"pos_key": nearest_key, "dist": nearest_dist}


# Shuffles the given Dictionary object. Does not return a copy.
func shuffle_dict(dict : Dictionary) -> void:
	var temp_arr := dict.values()
	randomize()
	temp_arr.shuffle()
	var index := 0
	for key: String in dict:
		dict[key] = temp_arr[index]
		index += 1
