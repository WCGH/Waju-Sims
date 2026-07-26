# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends P6Sequence

@onready var wings_1_anim: AnimationPlayer = %Wings1Anim

@onready var pc_positions := {
	"wings1": {
		"ne": {
			"t_near" : {"t2": Vector2(40, -35), "t1": Vector2(40, -3), "pt": Vector2(10, -20)},
			"t_far" : {"t2": Vector2(5, -40), "t1": Vector2(5, -5), "pt": Vector2(40, -5)}
		},
		"nw": {
			"t_near" : {"t2": Vector2(-5, -40), "t1": Vector2(-5, -5), "pt": Vector2(-30, -20)},
			"t_far" : {"t2": Vector2(-40, -5), "t1": Vector2(-40, -40), "pt": Vector2(-5, -5)}
		},
		"se": {
			"t_near" : {"t1": Vector2(40, 3), "t2": Vector2(40, 35), "pt": Vector2(10, 20)},
			"t_far" : {"t1": Vector2(5, 5), "t2": Vector2(5, 40), "pt": Vector2(40, 5)},
		},
		"sw": {
			"t_near" : {"t1": Vector2(-5, 5), "t2": Vector2(-5, 40), "pt": Vector2(-30, 20)},
			"t_far" : {"t1": Vector2(-40, 5), "t2": Vector2(-40, 40), "pt": Vector2(-5, 5)},
		}
	},
	"vow2": {
		"north": {
			"t1": Vector2(0, -1), "t2": Vector2(20, -18),
			"h1": Vector2(-4, -16), "h2": Vector2(4, -16),
			"m1": Vector2(-11, -18), "m2": Vector2(11, -18),
			"r1": Vector2(2, -20), "r2": Vector2(-3, -24)
		},
		"south": {
			"t1": Vector2(0, 1), "t2": Vector2(20, 18),
			"h1": Vector2(-4, 16), "h2": Vector2(4, 16),
			"m1": Vector2(-11, 18), "m2": Vector2(11, 18),
			"r1": Vector2(2, 20), "r2": Vector2(-3, 24)
		}
	}
}

var tanks_close: bool
var quadrants := ["ne", "nw", "se", "sw"]
var quad_index: int

# Needed to avoid duplicate ready calls in parent.
func _ready() -> void:
	pass


func start_sub_sequence() -> void:
	wings_1_anim.play("wings1")



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
			nid.move_to(npc_positions["db"]["ne"])
			look_at_v2(nid, npc_positions["db"]["se"])
		else: # South to North
			nid.move_to(npc_positions["db"]["se"])
			look_at_v2(nid, npc_positions["db"]["ne"])
	else: # East safe spot, West dive
		if randi() % 2 == 0:
			# North to South
			nid.move_to(npc_positions["db"]["nw"])
			look_at_v2(nid, npc_positions["db"]["sw"])
		else: # South to North
			nid.move_to(npc_positions["db"]["sw"])
			look_at_v2(nid, npc_positions["db"]["nw"])
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
		ground_aoe_controller.spawn_line(npc_positions["wings"]["se"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_positions["wings"]["sw"], 0.3,
			Color.AQUA, [0, 0, "Hallowed Wings"])
	else: # North Wings hit.
		ground_aoe_controller.spawn_line(npc_positions["wings"]["ne"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_positions["wings"]["nw"], 0.3,
			Color.AQUA, [0, 0, "Hallowed Wings"])
	# Spawn Divebomb AoE
	if quad_index == 0 or quad_index == 2: # West Divebomb.
		ground_aoe_controller.spawn_line(npc_positions["db"]["nw"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_positions["db"]["sw"], 0.3,
			Color.ORANGE_RED, [0, 0, "Cauterize (divebomb)"])
	else: # East Divebomb.
		ground_aoe_controller.spawn_line(npc_positions["db"]["ne"],
			DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, npc_positions["db"]["se"], 0.3,
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
			pc.add_debuff(vow_icon_scene, VOW_DURATION)
	vow_target.add_debuff(atonement_icon_scene, ATONEMENT_DURATION)
	test_timer.start()


func end_of_sub_sequence() -> void:
	play_sequence("wroth")


func move_party_to(key_1: String, key_2: String = "") -> void:
	var pos_dict: Dictionary = pc_positions[key_1] if key_2 == "" else pc_positions[key_1][key_2]
	for key: String in party:
		party[key].move_to(pos_dict[key])
