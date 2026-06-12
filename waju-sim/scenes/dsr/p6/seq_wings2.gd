# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends P6Sequence

@onready var wings_2_anim: AnimationPlayer = %Wings2Anim

@onready var pc_positions := {
	"wings2": {
		"in_n": {  # Safe spots. T2 is vow tank, near center.
			"t_near" : {"t1": Vector2(41, -5), "t2": Vector2(5, -5), "pt": Vector2(-30, -5)},
			"t_far" : {"t1": Vector2(-41, -5), "t2": Vector2(-5, -5), "pt": Vector2(30, -5)}
		},
		"out_n": {
			"t_near" : {"t1": Vector2(41, -25), "t2": Vector2(5, -25), "pt": Vector2(-30, -25)},
			"t_far" : {"t1": Vector2(-41, -25), "t2": Vector2(-5, -25), "pt": Vector2(30, -25)}
		},
		"in_s": {
			"t_near" : {"t1": Vector2(41, 5), "t2": Vector2(5, 5), "pt": Vector2(-30, 5)},
			"t_far" : {"t1": Vector2(-41, 5), "t2": Vector2(-5, 5), "pt": Vector2(30, 5)}
		},
		"out_s": {
			"t_near" : {"t1": Vector2(41, 25), "t2": Vector2(5, 25), "pt": Vector2(-30, 25)},
			"t_far" : {"t1": Vector2(-41, 25), "t2": Vector2(-5, 25), "pt": Vector2(30, 25)}
		}
	},
	"vow4": {
		"north": {
			"t1": Vector2(20, -18), "t2": Vector2(0, -1),
			"h1": Vector2(-4, -16), "h2": Vector2(4, -16),
			"m1": Vector2(-11, -18), "m2": Vector2(11, -18),
			"r1": Vector2(2, -20), "r2": Vector2(-3, -24)
		},
		"south": {
			"t1": Vector2(20, 18), "t2": Vector2(0, 1),
			"h1": Vector2(-4, 16), "h2": Vector2(4, 16),
			"m1": Vector2(-11, 18), "m2": Vector2(11, 18),
			"r1": Vector2(2, 20), "r2": Vector2(-3, 24)
		}
	}
}

var tanks_close: bool
var hot_wing: bool
var quadrants := ["in_n", "out_n", "in_s", "out_s"]
var quad_index: int
var melee_vow_target : PlayableCharacter


# Needed to avoid duplicate ready calls in parent.
func _ready() -> void:
	pass


func start_sub_sequence() -> void:
	print("Start of Wings2: ", test_timer.time_left)
	wings_2_anim.play("wings2")


# 4.4 - Wings1 Cast 8.25 (+ up/down anim + glow), Nidhogg land + cast Cauterize
func wings2_cast() -> void:
	# Cast wings
	target_cast_bar.cast("Hallowed Wings", 8.2, hra)
	enemy_cast_bar.start_cast_bar_1("Hallowed Wings", 8.2)
	# Determine safe spots (Hot Wing: 0/2, Left Wing (N safe): 0/1)
	quad_index = randi_range(0, 3)
	tanks_close = randi() % 2 == 0
	hot_wing = quad_index % 2 == 0
	toggle_wing_glow()
	# Up/Down anim
	if !tanks_close: # Tanks out, head up
		hra.start_up_cast()


# 6.5 - Cast Hot Wing/Tail
func cast_wing_tail() -> void:
	if !hot_wing:
		nid.start_up_cast()
	var cast_name := "Hot Wing" if hot_wing else "Hot Tail"
	target_cast_bar.cast(cast_name, 6.1, nid)
	enemy_cast_bar.start_cast_bar_2(cast_name, 6.1)


# 9.0 - Move to Wings safe spot
func move_to_wings_pos() -> void:
	var t_key := "t_near" if tanks_close else "t_far"
	for key: String in party:
		if key.contains("t"):
			party[key].move_to(pc_positions["wings2"][quadrants[quad_index]][t_key][key])
		else:
			party[key].move_to(pc_positions["wings2"][quadrants[quad_index]][t_key]["pt"])

# 12.1 - Hot Wing/Tail Tele
func hot_wing_tail_tele() -> void:
	# Finish Hrae cast
	if tanks_close: # Head down
		hra.finish_cast_down()
	else:
		hra.finish_cast()
	# Spawn Hot Wing/Tail. Finish Nid cast anim.
	if hot_wing:
		nid.finish_cast_down()
		ground_aoe_controller.spawn_line(npc_positions["north_wing"],
			HOT_WING_WIDTH, HOT_WING_LENGTH, npc_positions["north_wing_tar"],
			WING_TAIL_TELE_DURATION, Color.CORAL, [0, 0, "Hot Wing"], true)
		ground_aoe_controller.spawn_line(npc_positions["south_wing"],
			HOT_WING_WIDTH, HOT_WING_LENGTH, npc_positions["south_wing_tar"],
			WING_TAIL_TELE_DURATION, Color.CORAL, [0, 0, "Hot Wing"], true)
	else:
		nid.finish_cast()
		ground_aoe_controller.spawn_line(npc_positions["nid_spawn"],
			HOT_TAIL_WIDTH, HOT_TAIL_LENGTH, Vector2.ZERO,
			WING_TAIL_TELE_DURATION, Color.CORAL, [0, 0, "Hot Tail"], true)

# 12.6 - Wings/DB hit + proximity aoe's.
func wings2_hit() -> void:
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
		ground_aoe_controller.spawn_line(npc_positions["wings"]["se"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_positions["wings"]["sw"], 0.3,
			Color.AQUA, [0, 0, "Hallowed Wings"])
	else: # North Wings hit.
		ground_aoe_controller.spawn_line(npc_positions["wings"]["ne"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_positions["wings"]["nw"], 0.3,
			Color.AQUA, [0, 0, "Hallowed Wings"])
	toggle_wing_glow()
	

func toggle_wing_glow() -> void:
	if quad_index < 2:
		hra.toggle_left_wing()
	else:
		hra.toggle_right_wing()


# 17 - Move to vow pass positions (left or right).
func move_to_vow4() -> void:
	melee_vow_target = party["m2"] if vow_target == party["m1"] else party["m1"]
	if quad_index < 2: # Spread out north
		move_party_to("vow4", "north")
	else:
		move_party_to("vow4", "south")
	# Move Vow to middle
	melee_vow_target.move_to(Vector2(2, -2))


# 21.5 - Forth Vow pass (T2 to Melee) (34s), check + aoe
func vow_hit_4() -> void:
	# Spawn AoE
	var vow_hit: CircleAoe = ground_aoe_controller.spawn_circle(
		v2(party["t2"].global_position), VOW_RADIUS, 0.3, Color.WEB_PURPLE,
		[2, 2, "Mortal Vow Pass", [party["t2"], melee_vow_target]])
	# Add debuff to targets hit
	var targets_hit: Array = await vow_hit.get_collisions()
	for pc: PlayableCharacter in targets_hit:
		if pc != party["t2"]:
			pc.add_debuff(vow_icon_scene, 34.0)
	party["t2"].add_debuff(atonement_icon_scene, ATONEMENT_DURATION)


# 22.0
func end_of_sub_sequence() -> void:
	play_sequence("wyrm2")
	pass


## Utility


func move_party_to(key_1: String, key_2: String = "") -> void:
	var pos_dict: Dictionary = pc_positions[key_1] if key_2 == "" else pc_positions[key_1][key_2]
	for key: String in party:
		party[key].move_to(pos_dict[key])
