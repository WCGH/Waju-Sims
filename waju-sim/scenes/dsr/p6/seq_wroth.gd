# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends P6Sequence

const WROTH_DEBUFF_DURATION = 23
const WROTH_DEBUFF_RADIUS = 12.0
const AM_RADIUS = 12.0

@export var entangled_flames_icon_scene: PackedScene
@export var spreading_flames_icon_scene: PackedScene

@onready var wroth_anim: AnimationPlayer = %WrothAnim
@onready var wroth_flame_controller: WrothFlameController = %WrothFlameController
@onready var target_marker_controller: TargetMarkerController = %TargetMarkerController

var pc_positions := {
	"ne": {"a1": Vector2(40, -24), "a2": Vector2(21.5, -24), "a3": Vector2(0, -24)},
	"nw": {"a1": Vector2(-40, -24), "a2": Vector2(-21.5, -24), "a3": Vector2(0, -24)},
	"n_mid" : Vector2(0, -1),
	"se": {"a1": Vector2(40, 24), "a2": Vector2(21.5, 24), "a3": Vector2(0, 24)},
	"sw": {"a1": Vector2(-40, 24), "a2": Vector2(-21.5, 24), "a3": Vector2(0, 24)},
	"s_mid": Vector2(0, 1),
	"n_spread": {
		"wing": {
			"sp1": Vector2(-43, -7), "sp2": Vector2(-28, -7),
			"sp3": Vector2(-18, 7), "sp4": Vector2(-3, 7),
			"st1": Vector2(40, 0), "st2": Vector2(16, 0),
			"fr1": Vector2(39, 1), "fr2": Vector2(17, -1),
			},
		"tail": {
			"sp1": Vector2(-43, 25), "sp2": Vector2(-28, 25),
			"sp3": Vector2(-18, 40), "sp4": Vector2(-3, 40),
			"st1": Vector2(40, 30), "st2": Vector2(16, 30),
			"fr1": Vector2(39, 31), "fr2": Vector2(17, 29)
		}
	},
	"s_spread": {
		"wing": {
			"sp1": Vector2(43, 7), "sp2": Vector2(28, 7),
			"sp3": Vector2(18, -7), "sp4": Vector2(3, -7),
			"st1": Vector2(-40, 0), "st2": Vector2(-16, 0),
			"fr1": Vector2(-39, 1), "fr2": Vector2(-17, 1)
		},
		"tail": {
			"sp1": Vector2(43, -25), "sp2": Vector2(28, -25),
			"sp3": Vector2(18, -40), "sp4": Vector2(3, -40),
			"st1": Vector2(-40, -30), "st2": Vector2(-16, -30),
			"fr1": Vector2(-41, -31), "fr2": Vector2(-15, -29)
		}
	},
	"sn_spread": {
		"wing": {
			"sp1": Vector2(-43, 0), "sp2": Vector2(-28.6, 0),
			"sp3": Vector2(-14.3, 0), "sp4": Vector2(0, 0),
			"st1": Vector2(40, 0), "st2": Vector2(20, 0),
			"fr1": Vector2(39, 1), "fr2": Vector2(19, -1),
			},
		"tail": {
			"sp1": Vector2(-43, 28), "sp2": Vector2(-28.6, 28),
			"sp3": Vector2(-14.3, 28), "sp4": Vector2(0, 28),
			"st1": Vector2(40, 28), "st2": Vector2(20, 28),
			"fr1": Vector2(39, 29), "fr2": Vector2(19, 27),
		}
	},
	"ss_spread": {
		"wing": {
			"sp1": Vector2(-43, 0), "sp2": Vector2(-28.6, 0),
			"sp3": Vector2(-14.3, 0), "sp4": Vector2(0, 0),
			"st1": Vector2(40, 0), "st2": Vector2(20, 0),
			"fr1": Vector2(39, 1), "fr2": Vector2(19, -1),
		},
		"tail": {
			"sp1": Vector2(-43, -28), "sp2": Vector2(-28.6, -28),
			"sp3": Vector2(-14.3, -28), "sp4": Vector2(0, -28),
			"st1": Vector2(40, -28), "st2": Vector2(20, -28),
			"fr1": Vector2(39, -29), "fr2": Vector2(19, -27),
		}
	},
	
}

var am_dict := {
		DsrSavedVariables.t_markers.AM: {
			"st1": "link_1", "fr1": "link_2",
			"st2": "stop_1", "fr2": "stop_2",
			"sp1": "tar_1", "sp2": "tar_2",
			"sp3": "tar_3", "sp4": "tar_4"
		},
		DsrSavedVariables.t_markers.MANUAL: {
			"st1": "stop_1", "fr1": "link_1",
			"st2": "none", "fr2": "none",
			"sp1": "tar_1", "sp2": "tar_2",
			"sp3": "tar_3", "sp4": "tar_4"
		}
	}

var party_wroth: Dictionary
var party_list: Array
var divebomb_keys := ["nw", "sw", "n", "s", "ne", "se"]
var divebomb_index: int
var wroth_keys := ["st1", "st2", "fr1", "fr2", "sp1", "sp2", "sp3", "sp4"]
var quadrants := ["se", "ne", "sw", "nw"]
var quad_index: int
var south_orb: bool  # Pattern where second orb is closer to Nid
var hot_wing: bool
var am_puddles: Array[CircleAoe]
var db_target: Vector2
var am_snapshot: Vector2

# Needed to override parent _ready.
func _ready() -> void:
	pass


func start_sub_sequence() -> void:
	party_list = party.values()
	assign_debuffs()
	wroth_anim.play("wroth")
	print("Start of Wroth: ", test_timer.time_left)


func assign_debuffs() -> void:
	var wroth_list := party.values()
	wroth_list.shuffle()
	for i in wroth_list.size():
		party_wroth[wroth_keys[i]] = wroth_list[i]
	# Randomize Divebomb and Orb pattern
	south_orb = randi() % 2 == 0
	hot_wing = randi() % 2 == 0
	divebomb_index = randi_range(0, 5)
	# Magically determine safe quadrant
	quad_index = 0 if divebomb_index < 2 else 2
	if south_orb:
		quad_index += 1


# 2.5 - Wroth cast (3.5s), Nid start up cast
func cast_wroth() -> void:
	target_cast_bar.cast("Wroth Flames", 3.5, nid)
	enemy_cast_bar.start_cast_bar_1("Wroth Flames", 3.5)
	nid.start_up_cast()


# 5.5 - Nid finish up cast, Hrae jump
func hrae_jump() -> void:
	nid.finish_cast()
	hra.warp_out()
	target_controller.remove_targetable_npc(hra)
	wroth_flame_controller.instantiate_orbs(south_orb)


# 6.5 - Hrae Land, Assign Wroth debuffs (23s)
func add_debuffs() -> void:
	# Send debuffs
	for key: String in party_wroth:
		if key.contains("st"):
			party_wroth[key].add_debuff(entangled_flames_icon_scene, WROTH_DEBUFF_DURATION)
		elif key.contains("sp"):
			party_wroth[key].add_debuff(spreading_flames_icon_scene, WROTH_DEBUFF_DURATION)
	# Move Hrae
	if divebomb_keys[divebomb_index].contains("n"):
		db_target = npc_positions["db"][divebomb_keys[divebomb_index + 1]]
	else:
		db_target = npc_positions["db"][divebomb_keys[divebomb_index - 1]]
	hra.move_to(npc_positions["db"][divebomb_keys[divebomb_index]])
	look_at_v2(hra, db_target)


# 6.8
func warp_in_hra() -> void:
	hra.warp_in()


# 7.4 - First orbs appear
func orbs_1_spawn() -> void:
	wroth_flame_controller.show_orbs(0)


# 7.7 - Start Akh Morn Cast (8s)
func cast_akh_morn() -> void:
	target_cast_bar.cast("Akh Morn", 8.0, nid)
	enemy_cast_bar.start_cast_bar_1("Akh Morn", 8.0)


# 9.0 - Second orbs appear
func orbs_2_spawn() -> void:
	wroth_flame_controller.show_orbs(1)


# 10.7 - Cauterize cast (5.0s, enemy)
func cast_cauterize() -> void:
	enemy_cast_bar.start_cast_bar_2("Cauterize", 5.0)
	move_party_all(quadrants[quad_index], "a1")


# 12.2 - Third orbs appear
func orbs_3_spawn() -> void:
	wroth_flame_controller.show_orbs(2)
	add_player_markers()


# 16.0 - Start Hrae Divebomb Anim
func db_anim() -> void:
	hra.start_divebomb()


# 16.1 - Snapshot AM1
func snapshot_am_pos() -> void:
	am_snapshot = v2(party_list.pick_random().global_position)

# 16.5 - AM1 hit, Divebomb hit
func am_1_hit() -> void:
	# Activate AM puddle hitbox.
	am_puddles.append(ground_aoe_controller.spawn_circle(
		am_snapshot, AM_RADIUS, 14.5, Color.RED))
	# Divebomb hit.
	ground_aoe_controller.spawn_line(npc_positions["db"][divebomb_keys[divebomb_index]],
		DIVEBOMB_WIDTH, DIVEBOMB_LENGTH, db_target, 0.45,
		Color.PURPLE, [0, 0, "Cauterize (divebomb)"])


# 16.8 Move party
func move_party_am_1() -> void:
	move_party_all(quadrants[quad_index], "a2")


# 17.1 - First orb telegraph (1.4s)
func orb_1_tele() -> void:
	wroth_flame_controller.spawn_orb_telegraph(0)

# 17.8 - Snapshot AM2

# 18.2 - AM2 hit
func am_2_hit() -> void:
	am_puddles[0].circle_body_entered.connect(on_am_entered)
	am_puddles.append(ground_aoe_controller.spawn_circle(
		am_snapshot, AM_RADIUS, 14.5, Color.RED))



# 18.5 - First orb hit (despawn orbs), Move party to AM3 pos
func orb_1_hit() -> void:
	wroth_flame_controller.hide_orbs(0)
	move_party_all(quadrants[quad_index], "a3")


# 19.1 - Second orb telegraph (1.4s)
func orb_2_tele() -> void:
	wroth_flame_controller.spawn_orb_telegraph(1)

# 19.3 - Snapshot AM3.

# 19.7 - AM3 hit.
func am_3_hit() -> void:
	am_puddles[1].circle_body_entered.connect(on_am_entered)
	am_puddles.append(ground_aoe_controller.spawn_circle(
		am_snapshot, AM_RADIUS, 14.5, Color.RED))
	


# 20.5 - Second orb hit (despawn orbs),
func orb_2_hit() -> void:
	wroth_flame_controller.hide_orbs(1)
	# Move party to middle.
	if south_orb: # Coming from north
		move_party_all("n_mid")
	else:
		move_party_all("s_mid")

# 20.9 - Snapshot AM4,

# 21.3 - AM4 hit
func am_4_hit() -> void:
	am_puddles[2].circle_body_entered.connect(on_am_entered)
	am_puddles.append(ground_aoe_controller.spawn_circle(
		am_snapshot, AM_RADIUS, 14.5, Color.RED))
	# Hrae warps in
	hra.move_to(npc_positions["hra_spawn"])
	look_at_v2(hra, Vector2.ZERO)
	target_controller.add_targetable_npc(hra)
	hra.warp_in()


# 22.1 - Third orb tele, start Hot Wing/Tail cast (6.1s)
func orb_3_tele() -> void:
	am_puddles[3].circle_body_entered.connect(on_am_entered)
	wroth_flame_controller.spawn_orb_telegraph(2)
	if hot_wing:
		target_cast_bar.cast("Hot Wing", 6.1, nid)
		enemy_cast_bar.start_cast_bar_1("Hot Wing", 6.1)
	else:
		nid.start_up_cast()
		target_cast_bar.cast("Hot Tail", 6.1, nid)
		enemy_cast_bar.start_cast_bar_1("Hot Tail", 6.1)


# 23.6 - Third orb hit
func orb_3_hit() -> void:
	wroth_flame_controller.hide_orbs(2)


# 25 - Move party to spread pos.
func move_to_spread() -> void:
	var wing_tail := "wing" if hot_wing else "tail"
	var north_south: String
	if DsrSavedVariables.get_data("p6", "wroth") == DsrSavedVariables.wroth.J_RELATIVE:
		north_south = "n_spread" if south_orb else "s_spread"
	else:
		north_south = "sn_spread" if south_orb else "ss_spread"
	move_party(north_south, wing_tail)


# 27.7 - Wing/Tail telegraph (0.5s)
func tail_wing_tele() -> void:
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


# 29.4 - Debuffs expire
func debuff_aoe_hits() -> void:
	for key: String in party_wroth:
		if key.contains("st"):
			ground_aoe_controller.spawn_circle(v2(party_wroth[key].global_position), 
				WROTH_DEBUFF_RADIUS, 0.3, Color.PURPLE,
				[2, 2, "Entangled Flames (pair stack)", [party_wroth[key]]])
		elif key.contains("sp"):
			ground_aoe_controller.spawn_circle(v2(party_wroth[key].global_position), 
				WROTH_DEBUFF_RADIUS, 0.3, Color.ORANGE_RED,
				[1, 1, "Spreading Flames", [party_wroth[key]]])
				
	remove_player_markers()


# 30.3 - Move to vow pass positions
func move_tanks_to_middle() -> void:
	party["t1"].move_to(Vector2(1, 1))
	party["t2"].move_to(Vector2(-1, -1))
	# If wings, we need to move unmarked spread out of the way
	if party_wroth["sp4"] == party["t1"] or party_wroth["sp4"] == party["t2"]:
		return
	if hot_wing:
		if south_orb:
			party_wroth["sp4"].move_to(Vector2(-3, 15))
		else:
			party_wroth["sp4"].move_to(Vector2(3, -15))


# 33.3 - Vow Pass (always on T1, even if previous pass was done incorrectly).
func vow_hit_3() -> void:
	var vow_hit: CircleAoe = ground_aoe_controller.spawn_circle(
		v2(party["t1"].global_position), VOW_RADIUS, 0.3, Color.WEB_PURPLE,
		[2, 2, "Mortal Vow Pass", [party["t1"], party["t2"]]])
	# Add debuff to targets hit
	var targets_hit: Array = await vow_hit.get_collisions()
	for pc: PlayableCharacter in targets_hit:
		if pc != party["t1"]:
			pc.add_debuff(vow_icon_scene, 34.0)
	party["t1"].add_debuff(atonement_icon_scene, ATONEMENT_DURATION)

# 34 - End of sequence
func end_of_sub_sequence() -> void:
	play_sequence("aa2")


## Signals


func on_am_entered(body: CharacterBody3D, _circle: CircleAoe) -> void:
	fail_list.add_fail(str(body.name, " was hit by Akh Morn puddle."))


## Utility Methods
func add_player_markers() -> void:
	assign_am(DsrSavedVariables.get_data("p6", "t_markers"))


func assign_am(am_selection: int) -> void:
	if am_selection == DsrSavedVariables.t_markers.NONE:
		return
	
	for key: String in party_wroth:
		if am_dict[am_selection][key] == "none":
			continue
		target_marker_controller.add_marker(am_dict[am_selection][key], party_wroth[key])


func remove_player_markers() -> void:
	target_marker_controller.remove_all_markers()


func move_party_all(key_1: String, key_2: String = "") -> void:
	var pos: Vector2 = pc_positions[key_1] if key_2 == "" else pc_positions[key_1][key_2]
	for key: String in party:
		party[key].move_to(pos)


func move_party(key_1: String, key_2: String = "") -> void:
	var pos_dict: Dictionary = pc_positions[key_1] if key_2 == "" else pc_positions[key_1][key_2]
	for key: String in party_wroth:
		party_wroth[key].move_to(pos_dict[key])
