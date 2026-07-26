# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends P6Sequence

@onready var wyrm_1_anim: AnimationPlayer = %Wyrm1Anim
@onready var boss_hp_warn: Label = %BossHPWarn

@onready var pc_positions := {
	"wyrm1": {
		"left": Vector2(-9.77, 38.78), "right": Vector2(9.77, 38.78),
		"melee": Vector2(0, 17.45), "tanks": Vector2(0, -6),
		"t1": Vector2(-31.28, -24.58), "t2": Vector2(31.28, -24.58)
	},
	"vow1": {
		"t1": Vector2(-5.95, -13.62), "t2": Vector2(5.95, -13.62),
		"h1": Vector2(0, -9), "h2": Vector2(0, 9),
		"m1": Vector2(-19, 8), "m2": Vector2(19, 8),
		"r1": Vector2(-14.6, 24), "r2": Vector2(14.6, 24)
	},
}
var party_tether: Dictionary
var orb_config: int
var wb1_index: int
var first_vow: int


# Needed to avoid duplicate ready calls in parent. Needs TESTING
func _ready() -> void:
	# Get strat variables
	wb1_index = DsrSavedVariables.get_data("p6", "wb_1")
	#wb1_index = SavedVariables.save_data["p6"]["wb_1"]
	#if wb1_index == SavedVariables.wb_1.DEFAULT:
		#wb1_index = SavedVariables.get_default("p6", "wb_1")


func start_sub_sequence() -> void:
	assign_tethers()
	wyrm_1_anim.play("wyrm1")


func assign_tethers() -> void:
	var tether_party_list : Array = party.values()
	tether_party_list = tether_party_list.slice(2, 8)
	randomize()
	tether_party_list.shuffle()
	for i in tether_party_list.size():
		if i < 3:
			party_tether["ice%d" % i] = tether_party_list[i]
		else:
			party_tether["fire%d" % (i - 3)] = tether_party_list[i]


# 0:02.25 - Move to prepositions
func move_wyrm_pre() -> void:
	if wb1_index == DsrSavedVariables.wb_1.G1:
		# G1 anchor
		move_g1_anchor_pre()
	else:
		# Healers or Ranged anchor
		move_hr_anchor_pre()


func move_g1_anchor_pre() -> void:
	for key: String in party:
		if key.contains("t"):
			party[key].move_to(pc_positions["wyrm1"]["tanks"])
		elif key.contains("h"):
			party[key].move_to(pc_positions["wyrm1"]["left"]) 
		elif key.contains("m"):
			party[key].move_to(pc_positions["wyrm1"]["melee"]) 
		else:
			party[key].move_to(pc_positions["wyrm1"]["right"]) 


func move_hr_anchor_pre() -> void:
	for key: String in party:
		if key.contains("t"):
			party[key].move_to(pc_positions["wyrm1"]["tanks"])
		elif key.contains("m"):
			party[key].move_to(pc_positions["wyrm1"]["melee"])
		elif key == "h1" or key == "r1":
			party[key].move_to(pc_positions["wyrm1"]["left"])
		else:
			party[key].move_to(pc_positions["wyrm1"]["right"])


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
	if wb1_index == DsrSavedVariables.wb_1.G1:
		# G1 anchor
		move_g1_anchor_post()
	else:
		# Healers or Ranged anchor
		move_hr_anchor_post()


# Maybe fix this idk, it works.
func move_g1_anchor_post() -> void:
	var adjusters := []
	var adjusters_role := []
	if party_tether.find_key(party["h1"]).left(1) ==\
		party_tether.find_key(party["h2"]).left(1):
		adjusters.append("left")
		adjusters_role.append("h")
	if party_tether.find_key(party["m1"]).left(1) ==\
		party_tether.find_key(party["m2"]).left(1):
		adjusters.append("melee")
		adjusters_role.append("m")
	if adjusters.size() == 1:
		adjusters.append("right")
		adjusters_role.append("r")
	# Swap group 2 adjusters
	if adjusters.size() > 0:
		party[adjusters_role[0].left(1) + "2"].move_to(pc_positions["wyrm1"][adjusters[1]])
		party[adjusters_role[1].left(1) + "2"].move_to(pc_positions["wyrm1"][adjusters[0]])


func move_hr_anchor_post() -> void:
	var flexers := []
	var flexers_role := []
	if party_tether.find_key(party["m1"]).left(1) ==\
		party_tether.find_key(party["m2"]).left(1):
		flexers.append("melee")
		flexers_role.append("m")
	if party_tether.find_key(party["h1"]).left(1) ==\
		party_tether.find_key(party["r1"]).left(1):
		flexers.append("left")
		flexers_role.append("1")
	if flexers.size() == 1:
		flexers.append("right")
		flexers_role.append("2")
	# Swap group 2 flexers
	if flexers.size() == 0:
		return # Now swap needed
		
	# Get anchoring/flex roles
	var flexer_prefix := ""
	if wb1_index == DsrSavedVariables.wb_1.HEALERS:
		flexer_prefix = "r"
	elif wb1_index == DsrSavedVariables.wb_1.RANGED:
		flexer_prefix = "h"
	else:
		print("Error. Invalid wb_1 index was called in move_hr_anchor_post()")
		return
	if flexers[0] == "melee":
		party["m2"].move_to(pc_positions["wyrm1"][flexers[1]])
		party[flexer_prefix + flexers_role[1]].move_to(pc_positions["wyrm1"][flexers[0]])
	else:
		party[flexer_prefix + flexers_role[0]].move_to(pc_positions["wyrm1"][flexers[1]])
		party[flexer_prefix + flexers_role[1]].move_to(pc_positions["wyrm1"][flexers[0]])


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


func end_of_sub_sequence() -> void:
	play_sequence("aa1")


# Only used to move party to a dictionary with exact matching keys
func move_party_to(key_1: String, key_2: String = "") -> void:
	var pos_dict: Dictionary = pc_positions[key_1] if key_2 == "" else pc_positions[key_1][key_2]
	for key: String in party:
		party[key].move_to(pos_dict[key])
