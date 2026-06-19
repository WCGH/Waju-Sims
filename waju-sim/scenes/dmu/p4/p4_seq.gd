# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.


extends Node


enum Strat {KB}

## AoE Dimensions
# Mystery Magic Line
const MM_LINE_WIDTH := 23.5
const MM_LINE_LENGTH := 100.0
const MM_WEST_LINE_1_POS := Vector2(MM_LINE_WIDTH * -1.5, MM_LINE_LENGTH * -0.5)
const MM_WEST_LINE_1_TAR := Vector2(MM_LINE_WIDTH * -1.5, 0.0)
const MM_WEST_LINE_2_POS := Vector2(MM_LINE_WIDTH * 0.5, MM_LINE_LENGTH * -0.5)
const MM_WEST_LINE_2_TAR := Vector2(MM_LINE_WIDTH * 0.5, 0.0)
const MM_EAST_LINE_1_POS := Vector2(MM_LINE_WIDTH * -0.5, MM_LINE_LENGTH * -0.5)
const MM_EAST_LINE_1_TAR := Vector2(MM_LINE_WIDTH * -0.5, 0.0)
const MM_EAST_LINE_2_POS := Vector2(MM_LINE_WIDTH * 1.5, MM_LINE_LENGTH * -0.5)
const MM_EAST_LINE_2_TAR := Vector2(MM_LINE_WIDTH * 1.5, 0.0)
# Mystery Magic Cone
const MM_CONE_ANGLE := 127.5
const MM_CONE_LENGTH := 100.0
# Mystery Magic Common
const MM_TELE_LIFETIME := 4.7
const MM_HIT_LIFETIME := 0.4
const MM_TELE_COLOR := Color(0.493, 0.136, 0.594, 0.554)
const MM_ICE_HIT_COLOR := Color(0.694, 0.929, 1.0, 0.856)
const MM_THUNDER_HIT_COLOR := Color(0.147, 0.235, 0.76, 0.802)
# Water/Lightning AoE
const WATER_RADIUS := 25.0
const WATER_LIFETIME := 0.5
const WATER_COLOR := Color(0.577, 0.891, 0.937, 0.819)
const LIGHTNING_COLOR := Color(0.92, 0.674, 0.215, 0.771)
# Inferno/Tsunami
const INFERNO_OUTTER := 60.0
const INFERNO_INNER := 11.5
const INFERNO_LIFETIME := 0.8
const INFERNO_COLOR = Color(0.918, 0.49, 0.209, 0.819)
const TSUNAMI_COLOR := Color(0.541, 0.675, 0.76, 0.9)

const GAZE_MIN_ANGLE := 45.0
const GAZE_MAX_ANGLE := 315

# Position order NW CCW
const CHAOS_HEROS := ["t1", "h1", "m1", "m2"]
const EXDEATH_HEROS := ["t2", "h2", "r1", "r2"]
# Used prio to determine who is baiting wind pairs. Order is near > far from Chaos.
const BAIT_PRIO_SG := ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
#const BAIT_PRIO := ["h1", "h2", "t1", "t2", "r1", "r2", "m1", "m2"]
# Starting positions
const NEO_EXDEATH_NORTH := Vector2(0, -47)
const CHAOS_START_POS := Vector3(-10, 0, -20)
const SMALL_KEFKA_POS := Vector3(0, -1, -21.6)
const LEFT_TOWER_POS := Vector2(-22, 0)
const RIGHT_TOWER_POS := Vector2(22, 0)
const BIG_KEFKA_POS := Vector3.ZERO
const BIG_KEFKA_ROTA := Vector3.ZERO

## Debuff Durations
const SHORT_DEBUFF_1_DURATION := 50.0
const LONG_DEBUFF_1_DURATION := 75.0
const SHORT_DEBUFF_2_DURATION := 35.0
const LONG_DEBUFF_2_DURATION := 60.0
const FIRST_SHRIEK_DURATION := 60.0
const SECOND_SHRIEK_DURATION := 70.0
const INFERNO_LONG := 61.0
const TSUNAMI_LONG := 84.0
const INFERNO_SHORT := 45.0
const TSUNAMI_SHORT := 68.0
const FIELD_DEATH_DURATION := 14.0

## Debuff Icon Scenes
const DYNAMIC_FLUID_ICON = preload("uid://bver43oqosdyo")
const ENTROPY_ICON = preload("uid://dn4guqftdbd8i")
const ACCELETAION_BOMB_ICON = preload("uid://c5mrggq0muh5")
const ALLAGAN_FIELD_ICON = preload("uid://b64h6ifneco6t")
const BEYOND_DEATH_ICON = preload("uid://k5s72h16w5sb")
const BLACK_WOUND_ICON = preload("uid://bo7j338lavy7a")
const COMPRESSED_WATER_ICON = preload("uid://i8en5r82xfen")
const CURSED_SHRIEK_ICON = preload("uid://hfe8vr3b5giy")
const FORKED_LIGHTNING_ICON = preload("uid://dmhi4sys4ftfr")
const WHITE_WOUND_ICON = preload("uid://72mnilph48hp")
const DEBUFF_ORDER := ["black_wound", "white_wound", "beyond_death", "allagan_field", "cursed_shriek",
	"compressed_water", "forked_lightning", "acceleration_bomb", "entropy", "dynamic_fluid"]

@onready var kefka: P4Kefka = %Kefka
@onready var neo_exdeath: NeoExdeath = %NeoExdeath
@onready var lockon_controller: LockonController = %LockonController
@onready var target_cast_bar: TargetCastBar = %TargetCastBar
@onready var enemy_cast_bar: EnemyCastBar = %EnemyCastBar
@onready var target_controller: TargetController = %TargetController
@onready var chaos: P4Chaos = %Chaos
@onready var gac: GroundAoeController = %GroundAoEController
@onready var encounter_menu: CanvasLayer = %EncounterMenu
@onready var fail_list: FailList = %FailList
@onready var p4_anim: AnimationPlayer = %P4Anim


var party: Dictionary
var party_neo_1_keys: Dictionary = {
	"short_acc_dps": null, "long_acc_dps": null, "water_dps": null, "light_dps": null,
	"short_acc_sup": null, "long_acc_sup": null, "water_sup": null, "light_sup": null,
	"shriek_dps": null, "shriek_sup": null,
}
var party_neo_2_keys: Dictionary = {}
var party_neo_key_arr := ["short_acc_dps", "long_acc_dps", "water_dps", "light_dps",
		"short_acc_sup", "long_acc_sup", "water_sup", "light_sup"]
var strat: Strat
var arena_rotation_deg: float
var neo_rotation_deg: float
#var short_acc_keys: Array
#var long_acc_keys: Array
var player_key: String
var black_wound_keys: Array
var white_wound_keys: Array
var field_keys: Array
var death_keys: Array
var black_safe_keys: Array
var white_safe_keys: Array
var inferno_snapshot_pos := []
var tsunami_snaphot_pos := []
# Randomized variables
var short_water_neo_1: bool
var neo_1_fake: bool
var neo_2_fake: bool
var neo_3_fake: bool
var flood_fake: bool
var black_west: bool
var mm_thunder_fake: bool
var mm_ice_fake: bool
var mm_ns_ice: bool
var mm_west_line: bool
var mm_rotation_deg: float
var inferno_first: bool
var inferno_fake: bool
var tsunami_fake: bool
var mr_thunder_fake: bool
var mr_ice_fake: bool
# Saving MM positions for simplicity
var line_1_pos: Vector2
var line_1_tar: Vector2
var line_2_pos: Vector2
var line_2_tar: Vector2
var cone_1_tar: Vector2
var cone_2_tar: Vector2


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	gac.preload_aoe(["line", "circle", "cone", "donut"])
	#ResourceLoader.load_threaded_request(NEO_EXD_UID)
	target_controller.add_targetable_npc(kefka)
	#lockon_controller.pre_load([LockonController.STACK_MARKER])
	#player_key = Global.player_role_key
	## Get Strat and variables.
	#strat = DmuSavedVariables.save_data["settings"]["p4_strat"]
	instantiate_party(new_party)
	on_toggle_bots_visible()
	encounter_menu.toggle_bots_visible.connect(on_toggle_bots_visible)
	p4_anim.play("p4_anim")
	#p4_anim.play_section("p4_anim", 40.0)


func instantiate_party(new_party):
	party = new_party
	player_key = Global.player_role_key
	# RNG
	neo_1_fake = randi() % 2 == 0
	neo_2_fake = randi() % 2 == 0
	neo_3_fake = randi() % 2 == 0
	short_water_neo_1 = randi() % 2 == 0
	inferno_first = randi() % 2 == 0
	inferno_fake = randi() % 2 == 0
	tsunami_fake = randi() % 2 == 0
	flood_fake = randi() % 2 == 0
	black_west = randi() % 2 == 0
	mr_thunder_fake = randi() % 2 == 0
	mr_ice_fake = randi() % 2 == 0
	neo_rotation_deg = randi_range(0, 7) * 45.0
	var short_acc_gaze_1 =  randi() % 2 == 0
	var dps_keys = Global.DPS_ROLE_KEYS.duplicate()
	var sup_keys = Global.SUP_ROLE_KEYS.duplicate()
	dps_keys.shuffle()
	sup_keys.shuffle()
	party_neo_1_keys = {
		"short_acc_dps": dps_keys[0], "long_acc_dps": dps_keys[1], "water_dps": dps_keys[2], "light_dps": dps_keys[3],
		"short_acc_sup": sup_keys[0], "long_acc_sup": sup_keys[1], "water_sup": sup_keys[2], "light_sup": sup_keys[3],
	}
	party_neo_2_keys = {
		"short_acc_dps": dps_keys[2], "long_acc_dps": dps_keys[3], "water_dps": dps_keys[0], "light_dps": dps_keys[1],
		"short_acc_sup": sup_keys[2], "long_acc_sup": sup_keys[3], "water_sup": sup_keys[0], "light_sup": sup_keys[1],
	}
	# Randomize neo 2 assignments
	if randi() % 2 == 0:
		dict_swap(party_neo_2_keys, "short_acc_dps", "long_acc_dps")
	if randi() % 2 == 0:
		dict_swap(party_neo_2_keys, "water_dps", "light_dps")
	if randi() % 2 == 0:
		dict_swap(party_neo_2_keys, "short_acc_sup", "long_acc_sup")
	if randi() % 2 == 0:
		dict_swap(party_neo_2_keys, "water_sup", "light_sup")
	# Assign Shrieks
	if short_acc_gaze_1:
		party_neo_1_keys["shriek_dps"] = party_neo_1_keys["short_acc_dps"]
		party_neo_1_keys["shriek_sup"] = party_neo_1_keys["short_acc_sup"]
		party_neo_2_keys["shriek_dps"] = party_neo_1_keys["long_acc_dps"]
		party_neo_2_keys["shriek_sup"] = party_neo_1_keys["long_acc_sup"]
	else:
		party_neo_1_keys["shriek_dps"] = party_neo_1_keys["long_acc_dps"]
		party_neo_1_keys["shriek_sup"] = party_neo_1_keys["long_acc_sup"]
		party_neo_2_keys["shriek_dps"] = party_neo_1_keys["short_acc_dps"]
		party_neo_2_keys["shriek_sup"] = party_neo_1_keys["short_acc_sup"]
	# Grand Cross 3 (Black/White) setup
	var keys = party.keys().duplicate()
	keys.shuffle()
	field_keys = keys.slice(0, 4)
	death_keys = keys.slice(4, 8)
	for i in keys.size():
		if randi() % 2 == 0:
			black_wound_keys.append(keys[i])
			# If player has death Beyond Death, swap "safe" side.
			# Takes flood fake into account so don't check for this later.
			if i >= 4 != flood_fake:
				black_safe_keys.append(keys[i])
			else:
				white_safe_keys.append(keys[i])
		else:
			white_wound_keys.append(keys[i])
			if i >= 4 == flood_fake:
				black_safe_keys.append(keys[i])
			else:
				white_safe_keys.append(keys[i])


## START OF TIMELINE

# 03.3 - Kefka Cast Mysterious Magic (4.7s), Kefka orbs, telegraphs
func cast_mm():
	cast("Mysterious Magic", 4.7, kefka)
	mm_ice_fake = randi() % 2 == 0
	mm_thunder_fake = randi() % 2 == 0
	mm_ns_ice = randi() % 2 == 0
	mm_west_line = randi() % 2 == 0
	mm_rotation_deg = (randi_range(0, 3) * 90.0) + 45.0
	# Telegraphs
	kefka.show_orbs(mm_thunder_fake, mm_ice_fake)
	line_1_pos = MM_WEST_LINE_1_POS if mm_west_line else MM_EAST_LINE_1_POS
	line_1_pos = line_1_pos.rotated(deg_to_rad(mm_rotation_deg))
	line_1_tar = MM_WEST_LINE_1_TAR if mm_west_line else MM_EAST_LINE_1_TAR
	line_1_tar = line_1_tar.rotated(deg_to_rad(mm_rotation_deg))
	line_2_pos = MM_WEST_LINE_2_POS if mm_west_line else MM_EAST_LINE_2_POS
	line_2_pos = line_2_pos.rotated(deg_to_rad(mm_rotation_deg))
	line_2_tar = MM_WEST_LINE_2_TAR if mm_west_line else MM_EAST_LINE_2_TAR
	line_2_tar = line_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	cone_1_tar = Vector2.UP if mm_ns_ice else Vector2.LEFT
	cone_1_tar = cone_1_tar.rotated(deg_to_rad(mm_rotation_deg))
	cone_2_tar = Vector2.DOWN if mm_ns_ice else Vector2.RIGHT
	cone_2_tar = cone_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	gac.spawn_line(line_1_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_1_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_line(line_2_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_2_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_1_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_2_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)


# 03.6 - Cast Grand Cross (8.8s), Neo orbs, anim
func cast_gc(gc_num: int):
	neo_exdeath.play_gc_cast()
	var neo_fake: bool
	if gc_num == 1:
		neo_fake = neo_1_fake
	elif gc_num == 2:
		neo_fake = neo_2_fake
	elif gc_num == 3:
		neo_fake = neo_3_fake
	else:
		push_error("Invalid index in cast_gc.")
	enemy_cast_bar.cast("Grand Cross", 8.8)
	neo_exdeath.show_orbs(neo_fake)
	# TODO: GC cast anim


# 08.0 - Mysterious Magic hit
func mm_hit():
	kefka.hide_orbs()
	# Swap hit areas if fake
	if mm_thunder_fake:
		line_1_pos = MM_WEST_LINE_1_POS if !mm_west_line else MM_EAST_LINE_1_POS
		line_1_pos = line_1_pos.rotated(deg_to_rad(mm_rotation_deg))
		line_1_tar = MM_WEST_LINE_1_TAR if !mm_west_line else MM_EAST_LINE_1_TAR
		line_1_tar = line_1_tar.rotated(deg_to_rad(mm_rotation_deg))
		line_2_pos = MM_WEST_LINE_2_POS if !mm_west_line else MM_EAST_LINE_2_POS
		line_2_pos = line_2_pos.rotated(deg_to_rad(mm_rotation_deg))
		line_2_tar = MM_WEST_LINE_2_TAR if !mm_west_line else MM_EAST_LINE_2_TAR
		line_2_tar = line_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	if mm_ice_fake:
		cone_1_tar = Vector2.UP if !mm_ns_ice else Vector2.LEFT
		cone_1_tar = cone_1_tar.rotated(deg_to_rad(mm_rotation_deg))
		cone_2_tar = Vector2.DOWN if !mm_ns_ice else Vector2.RIGHT
		cone_2_tar = cone_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	gac.spawn_line(line_1_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_1_tar, MM_HIT_LIFETIME, MM_THUNDER_HIT_COLOR, [0, 0, "Mysterious Magic (Line)"])
	gac.spawn_line(line_2_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_2_tar, MM_HIT_LIFETIME, MM_THUNDER_HIT_COLOR, [0, 0, "Mysterious Magic (Line)"])
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_1_tar, MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Mysterious Magic (Cone)"])
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_2_tar, MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Mysterious Magic (Cone)"])


# 08.7 - Cast Inferno/Tsunami (8.7s), Chaos orbs
func cast_chaos(num: int):
	if (num == 1 and inferno_first) or (num == 2 and !inferno_first):
		enemy_cast_bar.cast("Inferno", 8.7)
		chaos.show_orbs(inferno_fake)
	else:
		enemy_cast_bar.cast("Tsunami", 8.7)
		chaos.show_orbs(tsunami_fake)


# 12.6 - Assign Neo debuffs 1 (2 Lightning, 2 Water, 4 Accel (2 short/2 long), 2 Shriek)
func neo_debuffs(neo_num: int):
	assert(neo_num == 1 or neo_num == 2)
	neo_exdeath.play_gc_finish()
	neo_exdeath.hide_orbs()
	# Short Acceleration
	var debuff_duration = SHORT_DEBUFF_1_DURATION if neo_num == 1 else SHORT_DEBUFF_2_DURATION
	neo_pc(neo_num, "short_acc_dps").add_debuff(ACCELETAION_BOMB_ICON, debuff_duration, false, "acceleration_bomb")
	neo_pc(neo_num, "short_acc_sup").add_debuff(ACCELETAION_BOMB_ICON, debuff_duration, false, "acceleration_bomb")
	# Long Acceleration
	debuff_duration = LONG_DEBUFF_1_DURATION if neo_num == 1 else LONG_DEBUFF_2_DURATION
	neo_pc(neo_num, "long_acc_dps").add_debuff(ACCELETAION_BOMB_ICON, debuff_duration, false, "acceleration_bomb")
	neo_pc(neo_num, "long_acc_sup").add_debuff(ACCELETAION_BOMB_ICON, debuff_duration, false, "acceleration_bomb")
	# Water/Lightning
	if neo_num == 1:
		debuff_duration = SHORT_DEBUFF_1_DURATION if short_water_neo_1 else LONG_DEBUFF_1_DURATION
	elif neo_num ==2 :
		debuff_duration = SHORT_DEBUFF_2_DURATION if !short_water_neo_1 else LONG_DEBUFF_2_DURATION
	neo_pc(neo_num, "water_dps").add_debuff(COMPRESSED_WATER_ICON, debuff_duration, false, "compressed_water")
	neo_pc(neo_num, "water_sup").add_debuff(COMPRESSED_WATER_ICON, debuff_duration, false, "compressed_water")
	neo_pc(neo_num, "light_dps").add_debuff(FORKED_LIGHTNING_ICON, debuff_duration, false, "forked_lightning")
	neo_pc(neo_num, "light_sup").add_debuff(FORKED_LIGHTNING_ICON, debuff_duration, false, "forked_lightning")
	# Shriek
	debuff_duration = FIRST_SHRIEK_DURATION if neo_num == 1 else SECOND_SHRIEK_DURATION
	neo_pc(neo_num, "shriek_dps").add_debuff(CURSED_SHRIEK_ICON, debuff_duration, false, "cursed_shriek")
	neo_pc(neo_num, "shriek_sup").add_debuff(CURSED_SHRIEK_ICON, debuff_duration, false, "cursed_shriek")
	order_debuffs()


# 18.2 - Cast Mystery Magic (4.7s), Kefka orbs, telegraphs
## cast_mm()

# 18.4 - Assign Chaos Debuffs (Entropy/Fluid)
func chaos_debuffs(num: int):
	assert(num == 1 or num == 2)
	chaos.hide_orbs()
	if (inferno_first and num == 1) or (!inferno_first and num == 2):
		var duration = INFERNO_LONG if num == 1 else INFERNO_SHORT
		for key in party:
			party[key].add_debuff(ENTROPY_ICON, duration, false, "entropy")
	else:
		var duration = TSUNAMI_LONG if num == 1 else TSUNAMI_SHORT
		for key in party:
			party[key].add_debuff(DYNAMIC_FLUID_ICON, duration, false, "dynamic_fluid")
	order_debuffs()

# 18.5 - Cast Grand Cross 2 (8.8s), Neo orbs
## cast_gc(2)

# 22.9 - Mystery Magic Hit
## mm_hit()

# 23.7 - Cast Inferno/Tsunami (8.7s), Chaos orbs
## cast_chaos(2)

# 27.6 - Assign Neo debuffs 2 (2 Lightning, 2 Water, 4 Accel, 2 Shriek)
## neo_debuffs(2)

# 33.4 - Cast Mystery Magic (4.7s), Kefka orbs, telegraphs
## cast_mm()

# 33.6 - Cast Grand Cross (8.8s), Neo orbs
## cast_gc(3)

# 34.4 - Assign Chaos Debuffs 2 (Entropy/Fluid) 
## chaos_debuffs(2)

# 38.1 - Mystery Magic Hit
## mm_hit()

# 44.0 - Assign Neo Debuffs 3 (Wound + Field/Death)
func neo_debuffs_3():
	kefka.get_model().play_float_to_lounge()
	neo_exdeath.play_gc_finish()
	neo_exdeath.hide_orbs()
	for key in black_wound_keys:
		party[key].add_debuff(BLACK_WOUND_ICON, 0.0, false, "black_wound")
	for key in white_wound_keys:
		party[key].add_debuff(WHITE_WOUND_ICON, 0.0, false, "white_wound")
	for key in death_keys:
		party[key].add_debuff(BEYOND_DEATH_ICON, FIELD_DEATH_DURATION, false, "beyond_death")
	for key in field_keys:
		party[key].add_debuff(ALLAGAN_FIELD_ICON, FIELD_DEATH_DURATION, false, "allagan_field")
	order_debuffs()


# 46.0 - Neo fade out
func neo_fade_out():
	neo_exdeath.play_fade_out()


# 47.5 - Neo fade in random inter
func neo_move_fade_in():
	var pos = NEO_EXDEATH_NORTH.rotated(deg_to_rad(neo_rotation_deg))
	neo_exdeath.global_position = Vector3(pos.x, 3.25, pos.y)
	neo_exdeath.rotation_degrees.y = -neo_rotation_deg
	neo_exdeath.play_fade_in()


# 49.7 - Cast Flood of Naughts (5.3s), Neo orbs + Flood orbs, anim
func flood_cast():
	enemy_cast_bar.cast("Flood of Naughts", 5.3)
	neo_exdeath.show_antilight(black_west)
	neo_exdeath.show_orbs(flood_fake)
	neo_exdeath.play_gc_cast()


# 55.0 - Flood Hit
func flood_hit():
	kefka.get_model().play_lounge_to_float()
	neo_exdeath.hide_antilight()
	neo_exdeath.hide_orbs()
	neo_exdeath.play_gc_finish()
	# For visual only, will check black/light in code
	gac.spawn_line(v2(neo_exdeath.global_position), 100.0, 100.0, Vector2.ZERO, 0.2, Color(0.69, 0.81, 0.84, 0.48))
	for key in party:
		# Get position relative to Neo North.
		var pos = v2(party[key].global_position).rotated(deg_to_rad(-neo_rotation_deg))
		if black_west == black_safe_keys.has(key):
			if pos.x > 0.0:
				if party[key].is_player():
					fail_list.add_fail("Player was hit by wrong Anitlight.")
				else:
					fail_list.add_fail(party[key].get_role_name() + " was hit by wrong Anitlight.")
		elif pos.x < 0.0:
			if party[key].is_player():
				fail_list.add_fail("Player was hit by wrong Anitlight.")
			else:
				fail_list.add_fail(party[key].get_role_name() + " was hit by wrong Anitlight.")
		party[key].remove_debuff("black_wound")
		party[key].remove_debuff("white_wound")

# 63.8 - Short Neo Debuffs Hit (Water/Lightning + Short Accel)
func short_debuff_hit():
	var fail_conditions: Array
	var short_dict_num = 1 if short_water_neo_1 else 2
	# Short Waters
	if (short_water_neo_1 and neo_1_fake) or (!short_water_neo_1 and neo_2_fake):
		fail_conditions = [1, 1, "Compressed Water (Fake)", [neo_pc(short_dict_num, "water_dps"), neo_pc(short_dict_num, "water_sup")]]
	else:
		fail_conditions = [3, 3, "Compressed Water"]
	gac.spawn_circle(v2(neo_pc(short_dict_num, "water_dps").global_position), WATER_RADIUS,
		WATER_LIFETIME, WATER_COLOR, fail_conditions)
	gac.spawn_circle(v2(neo_pc(short_dict_num, "water_sup").global_position), WATER_RADIUS,
		WATER_LIFETIME, WATER_COLOR, fail_conditions)
	# Short Lightnings
	if (short_water_neo_1 and neo_1_fake) or (!short_water_neo_1 and neo_2_fake):
		fail_conditions = [3, 3, "Forked Lightning (Fake)", [neo_pc(short_dict_num, "light_dps"), neo_pc(short_dict_num, "light_sup")]]
	else:
		fail_conditions = [1, 1, "Forked Lightning"]
	gac.spawn_circle(v2(neo_pc(short_dict_num, "light_dps").global_position), WATER_RADIUS,
		WATER_LIFETIME, LIGHTNING_COLOR, fail_conditions)
	gac.spawn_circle(v2(neo_pc(short_dict_num, "light_sup").global_position), WATER_RADIUS,
		WATER_LIFETIME, LIGHTNING_COLOR, fail_conditions)
	# Check player acceleration (ignore bots).
	if Global.spectate_mode:
		return
	if party_neo_1_keys.find_key(player_key).contains("short_acc"):
		if neo_1_fake:
			# Check motion
			if party[player_key].velocity.length_squared() < 1.0:
				fail_list.add_fail("Player failed to move during Acceleration Bomb (Fake).")
		else:
			# Check stillness
			if party[player_key].velocity.length_squared() > 0.1:
				fail_list.add_fail("Player moved during Acceleration Bomb.")
	elif party_neo_2_keys.find_key(player_key).contains("short_acc"):
		if neo_2_fake:
			if party[player_key].velocity.length_squared() < 1.0:
				fail_list.add_fail("Player failed to move during Acceleration Bomb (Fake).")
		else:
			if party[player_key].velocity.length_squared() > 0.1:
				fail_list.add_fail("Player moved during Acceleration Bomb.")


# 66.7 - Kefka Cast Thrumming Thunder III (4.7s), Kefka orb, tele
func cast_tt():
	cast("Thrumming Thunder III", 4.7, kefka)
	# Setup for TT (thunder) and BB (ice)
	mm_ice_fake = randi() % 2 == 0
	mm_thunder_fake = randi() % 2 == 0
	# Use mm_variables for AoE pos
	mm_ns_ice = randi() % 2 == 0
	mm_west_line = randi() % 2 == 0
	mm_rotation_deg = (randi_range(0, 3) * 90.0) + 45.0
	kefka.show_thunder_orb(mm_thunder_fake)
	# TT Telegraph
	line_1_pos = MM_WEST_LINE_1_POS if mm_west_line else MM_EAST_LINE_1_POS
	line_1_pos = line_1_pos.rotated(deg_to_rad(mm_rotation_deg))
	line_1_tar = MM_WEST_LINE_1_TAR if mm_west_line else MM_EAST_LINE_1_TAR
	line_1_tar = line_1_tar.rotated(deg_to_rad(mm_rotation_deg))
	line_2_pos = MM_WEST_LINE_2_POS if mm_west_line else MM_EAST_LINE_2_POS
	line_2_pos = line_2_pos.rotated(deg_to_rad(mm_rotation_deg))
	line_2_tar = MM_WEST_LINE_2_TAR if mm_west_line else MM_EAST_LINE_2_TAR
	line_2_tar = line_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	gac.spawn_line(line_1_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_1_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_line(line_2_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_2_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)



# 71.4 - TT Hit
func tt_hit():
	kefka.hide_orbs()
	# Swap hit areas if fake
	# Assigning new vars here so we can reuse old positions for Mana Release.
	if mm_thunder_fake:
		var tt_line_1_pos = MM_WEST_LINE_1_POS if !mm_west_line else MM_EAST_LINE_1_POS
		tt_line_1_pos = tt_line_1_pos.rotated(deg_to_rad(mm_rotation_deg))
		var tt_line_1_tar = MM_WEST_LINE_1_TAR if !mm_west_line else MM_EAST_LINE_1_TAR
		tt_line_1_tar = tt_line_1_tar.rotated(deg_to_rad(mm_rotation_deg))
		var tt_line_2_pos = MM_WEST_LINE_2_POS if !mm_west_line else MM_EAST_LINE_2_POS
		tt_line_2_pos = tt_line_2_pos.rotated(deg_to_rad(mm_rotation_deg))
		var tt_line_2_tar = MM_WEST_LINE_2_TAR if !mm_west_line else MM_EAST_LINE_2_TAR
		tt_line_2_tar = tt_line_2_tar.rotated(deg_to_rad(mm_rotation_deg))
		gac.spawn_line(tt_line_1_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, tt_line_1_tar, MM_HIT_LIFETIME,
			MM_THUNDER_HIT_COLOR, [0, 0, "Thrumming Thunder (Line)"])
		gac.spawn_line(tt_line_2_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, tt_line_2_tar, MM_HIT_LIFETIME,
			MM_THUNDER_HIT_COLOR, [0, 0, "Thrumming Thunder (Line)"])
	else:
		gac.spawn_line(line_1_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_1_tar, MM_HIT_LIFETIME,
			MM_THUNDER_HIT_COLOR, [0, 0, "Thrumming Thunder (Line)"])
		gac.spawn_line(line_2_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_2_tar, MM_HIT_LIFETIME,
			MM_THUNDER_HIT_COLOR, [0, 0, "Thrumming Thunder (Line)"])


# 72.8 - Shriek 1 Hit. Only check player
func shriek_1_hit():
	if Global.spectate_mode:
		return
	var shriek_1_pos := neo_pc(1, "shriek_dps").global_position
	var shriek_2_pos := neo_pc(1, "shriek_sup").global_position
	if (check_if_facing(party[player_key], shriek_1_pos) or check_if_facing(party[player_key], shriek_2_pos)) and !neo_1_fake:
		fail_list.add_fail("Player looked at Cursed Shriek.")
	if (!check_if_facing(party[player_key], shriek_1_pos) or !check_if_facing(party[player_key], shriek_2_pos)) and neo_1_fake:
		fail_list.add_fail("Player failed to look at Cursed Shriek (Fake).")


# 76.9 - Kefka Cast Ultima Upsurge (4.7s)
func cast_ultima():
	cast("Ultima Upsurge", 4.7, kefka)


# 79.4 - Short Chaos Debuff Expire (Entropy/Fluid), snapshot entropy twisters
func snapshot_inferno():
	for key in party:
		inferno_snapshot_pos.append(v2(party[key].global_position))


# 83.5 - Twisters hit (with raidwide)
func inferno_hit():
	for pos in inferno_snapshot_pos:
		if inferno_fake:
			gac.spawn_donut(pos, INFERNO_INNER, INFERNO_OUTTER, INFERNO_LIFETIME, INFERNO_COLOR, [0, 0, "Entropy Donut (Twister, Fake)"])
		else:
			gac.spawn_circle(pos, INFERNO_INNER, INFERNO_LIFETIME, INFERNO_COLOR, [0, 0, "Entropy AoE (Twister)"])


# 84.7 - Kefka Cast Blizzard Blowout III (4.7s), Kefka orb, tele 
func cast_bb():
	cast("Blizzard Blowout III", 4.7, kefka)
	kefka.show_ice_orb(mm_ice_fake)
	# BB Telegraph
	cone_1_tar = Vector2.UP if mm_ns_ice else Vector2.LEFT
	cone_1_tar = cone_1_tar.rotated(deg_to_rad(mm_rotation_deg))
	cone_2_tar = Vector2.DOWN if mm_ns_ice else Vector2.RIGHT
	cone_2_tar = cone_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_1_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_2_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)


# 88.7 - Long Neo Debuffs Hit (Water/Lightning + Long Accel)
func long_debuff_hit():
	var fail_conditions: Array
	var long_dict_num = 2 if short_water_neo_1 else 1
	# Long Waters
	if (!short_water_neo_1 and neo_1_fake) or (short_water_neo_1 and neo_2_fake):
		fail_conditions = [1, 1, "Compressed Water (Fake)", [neo_pc(long_dict_num, "water_dps"), neo_pc(long_dict_num, "water_sup")]]
	else:
		fail_conditions = [3, 3, "Compressed Water"]
	gac.spawn_circle(v2(neo_pc(long_dict_num, "water_dps").global_position), WATER_RADIUS,
		WATER_LIFETIME, WATER_COLOR, fail_conditions)
	gac.spawn_circle(v2(neo_pc(long_dict_num, "water_sup").global_position), WATER_RADIUS,
		WATER_LIFETIME, WATER_COLOR, fail_conditions)
	# Long Lightnings
	if (!short_water_neo_1 and neo_1_fake) or (short_water_neo_1 and neo_2_fake):
		fail_conditions = [3, 3, "Forked Lightning (Fake)", [neo_pc(long_dict_num, "light_dps"), neo_pc(long_dict_num, "light_sup")]]
	else:
		fail_conditions = [1, 1, "Forked Lightning"]
	gac.spawn_circle(v2(neo_pc(long_dict_num, "light_dps").global_position), WATER_RADIUS,
		WATER_LIFETIME, LIGHTNING_COLOR, fail_conditions)
	gac.spawn_circle(v2(neo_pc(long_dict_num, "light_sup").global_position), WATER_RADIUS,
		WATER_LIFETIME, LIGHTNING_COLOR, fail_conditions)
	# Check player acceleration (ignore bots).
	if Global.spectate_mode:
		return
	if party_neo_1_keys.find_key(player_key).contains("long_acc"):
		if neo_1_fake:
			# Check motion
			if party[player_key].velocity.length_squared() < 1.0:
				fail_list.add_fail("Player failed to move during Acceleration Bomb (Fake).")
		else:
			# Check stillness
			if party[player_key].velocity.length_squared() > 0.1:
				fail_list.add_fail("Player moved during Acceleration Bomb.")
	elif party_neo_2_keys.find_key(player_key).contains("long_acc"):
		if neo_2_fake:
			if party[player_key].velocity.length_squared() < 1.0:
				fail_list.add_fail("Player failed to move during Acceleration Bomb (Fake).")
		else:
			if party[player_key].velocity.length_squared() > 0.1:
				fail_list.add_fail("Player moved during Acceleration Bomb.")


# 89.4 - BB Hit
func bb_hit():
	kefka.hide_orbs()
	# Swap hit areas if fake
	# Assigning new vars here so we can reuse old positions for Mana Release.
	if mm_ice_fake:
		var bb_cone_1_tar = Vector2.UP if !mm_ns_ice else Vector2.LEFT
		bb_cone_1_tar = bb_cone_1_tar.rotated(deg_to_rad(mm_rotation_deg))
		var bb_cone_2_tar = Vector2.DOWN if !mm_ns_ice else Vector2.RIGHT
		bb_cone_2_tar = bb_cone_2_tar.rotated(deg_to_rad(mm_rotation_deg))
		gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, bb_cone_1_tar,
			MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Blizzard Blowout (Cone)"])
		gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, bb_cone_2_tar,
			MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Blizzard Blowout (Cone)"])
	else:
		gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_1_tar,
			MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Blizzard Blowout (Cone)"])
		gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_2_tar,
			MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Blizzard Blowout (Cone)"])


# 95.9 - Cast Mana Release (6.7s), Kefka orbs
func cast_mr():
	cast("Mana Release", 6.7, kefka)
	kefka.show_orbs(mr_thunder_fake, mr_ice_fake)


# 96.7 - Shriek 2 Hit
func shriek_2_hit():
	if Global.spectate_mode:
		return
	var shriek_1_pos := neo_pc(2, "shriek_dps").global_position
	var shriek_2_pos := neo_pc(2, "shriek_sup").global_position
	if (check_if_facing(party[player_key], shriek_1_pos) or check_if_facing(party[player_key], shriek_2_pos)) and !neo_2_fake:
		fail_list.add_fail("Player looked at Cursed Shriek.")
	if (!check_if_facing(party[player_key], shriek_1_pos) or !check_if_facing(party[player_key], shriek_2_pos)) and neo_2_fake:
		fail_list.add_fail("Player failed to look at Cursed Shriek (Fake).")


# 102.4 - Long Chaos Debuff Expite (Entropy/Fluid), snapshot fluid twisters
func snapshot_tsunami():
	for key in party:
		tsunami_snaphot_pos.append(v2(party[key].global_position))


# 102.8 - Show MR Tele
func show_mr_tele():
	kefka.hide_orbs()
	gac.spawn_line(line_1_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_1_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_line(line_2_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_2_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_1_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_2_tar, MM_TELE_LIFETIME, MM_TELE_COLOR)


# 107.5 MR Hit with Twisters
func mr_hit():
	if mr_thunder_fake != mm_thunder_fake:
		line_1_pos = MM_WEST_LINE_1_POS if !mm_west_line else MM_EAST_LINE_1_POS
		line_1_pos = line_1_pos.rotated(deg_to_rad(mm_rotation_deg))
		line_1_tar = MM_WEST_LINE_1_TAR if !mm_west_line else MM_EAST_LINE_1_TAR
		line_1_tar = line_1_tar.rotated(deg_to_rad(mm_rotation_deg))
		line_2_pos = MM_WEST_LINE_2_POS if !mm_west_line else MM_EAST_LINE_2_POS
		line_2_pos = line_2_pos.rotated(deg_to_rad(mm_rotation_deg))
		line_2_tar = MM_WEST_LINE_2_TAR if !mm_west_line else MM_EAST_LINE_2_TAR
		line_2_tar = line_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	if mr_ice_fake != mm_ice_fake:
		cone_1_tar = Vector2.UP if !mm_ns_ice else Vector2.LEFT
		cone_1_tar = cone_1_tar.rotated(deg_to_rad(mm_rotation_deg))
		cone_2_tar = Vector2.DOWN if !mm_ns_ice else Vector2.RIGHT
		cone_2_tar = cone_2_tar.rotated(deg_to_rad(mm_rotation_deg))
	gac.spawn_line(line_1_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_1_tar, MM_HIT_LIFETIME, MM_THUNDER_HIT_COLOR, [0, 0, "Mana Release (Line)"])
	gac.spawn_line(line_2_pos, MM_LINE_WIDTH, MM_LINE_LENGTH, line_2_tar, MM_HIT_LIFETIME, MM_THUNDER_HIT_COLOR, [0, 0, "Mana Release (Line)"])
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_1_tar, MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Mana Release (Cone)"])
	gac.spawn_cone(Vector2.ZERO, MM_CONE_ANGLE, MM_CONE_LENGTH, cone_2_tar, MM_HIT_LIFETIME, MM_ICE_HIT_COLOR, [0, 0, "Mana Release (Cone)"])
	tsunami_hit()


func tsunami_hit():
	for pos in tsunami_snaphot_pos:
		if tsunami_fake:
			gac.spawn_circle(pos, INFERNO_INNER, INFERNO_LIFETIME, TSUNAMI_COLOR, [0, 0, "Dynamic Fluid AoE (Twister)"])
		else:
			gac.spawn_donut(pos, INFERNO_INNER, INFERNO_OUTTER, INFERNO_LIFETIME, TSUNAMI_COLOR, [0, 0, "Dynamic Fluid Donut (Twister, Fake)"])


# 115.6 Kefka Cast Ultima Upsurge (4.7s)
## cast_ultima()


## END OF TIMELINE



## START OF BOT MOVEMENT

func move_mm_dodge():
	if mm_ns_ice != mm_ice_fake:
		# NS Ice West Line
		if mm_west_line != mm_thunder_fake:
			move_party_mm(P4Pos.MM_NS_WEST_POS)
		# NS East
		else:
			move_party_mm(P4Pos.MM_NS_EAST_POS)
	else:
		# EW West
		if mm_west_line != mm_thunder_fake:
			move_party_mm(P4Pos.MM_EW_WEST_POS)
		# EW East
		else:
			move_party_mm(P4Pos.MM_EW_EAST_POS)


func move_flood_dodge():
	for key in black_safe_keys:
		if black_west:
			party[key].move_to(P4Pos.FLOOD_WEST_POS[key].rotated(deg_to_rad(neo_rotation_deg)))
		else:
			party[key].move_to(P4Pos.FLOOD_EAST_POS[key].rotated(deg_to_rad(neo_rotation_deg)))
	for key in white_safe_keys:
		if black_west:
			party[key].move_to(P4Pos.FLOOD_EAST_POS[key].rotated(deg_to_rad(neo_rotation_deg)))
		else:
			party[key].move_to(P4Pos.FLOOD_WEST_POS[key].rotated(deg_to_rad(neo_rotation_deg)))


func move_short_debuff():
	var short_keys = party_neo_1_keys if short_water_neo_1 else party_neo_2_keys
	var dict_num = 1 if short_water_neo_1 else 2
	var short_fake = neo_1_fake if short_water_neo_1 else neo_2_fake
	for key: String in short_keys:
		if key.contains("shriek"):
			continue
		if key.contains("acc_dps"):
			neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["dps_water"])
		elif key.contains("acc_sup"):
			neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["sup_water"])
		elif key == "water_dps":
			if short_fake:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["dps_light"])
			else:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["dps_water"])
		elif key == "light_dps":
			if short_fake:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["dps_water"])
			else:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["dps_light"])
		elif key == "water_sup":
			if short_fake:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["sup_light"])
			else:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["sup_water"])
		elif key == "light_sup":
			if short_fake:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["sup_water"])
			else:
				neo_pc(dict_num, key).move_to(P4Pos.DEBUFF_POS["sup_light"])


# With BB dodge
func move_long_debuff():
	var long_keys = party_neo_1_keys if !short_water_neo_1 else party_neo_2_keys
	var dict_num = 1 if !short_water_neo_1 else 2
	var long_fake = neo_1_fake if !short_water_neo_1 else neo_2_fake
	# Get position based on ice
	var pos_dict: Dictionary
	# NS Ice
	if mm_ns_ice != mm_ice_fake:
		if mm_rotation_deg == 135.0 or mm_rotation_deg == 315.0:
			pos_dict = P4Pos.DEBUFF_POS_NE_SW
		else:
			pos_dict = P4Pos.DEBUFF_POS_NW_SE
	# EW Ice
	else:
		if mm_rotation_deg == 45.0 or mm_rotation_deg == 225.0:
			pos_dict = P4Pos.DEBUFF_POS_NE_SW
		else:
			pos_dict = P4Pos.DEBUFF_POS_NW_SE
	
	for key: String in long_keys:
		if key.contains("acc_dps"):
			neo_pc(dict_num, key).move_to(pos_dict["dps_water"])
		elif key.contains("acc_sup"):
			neo_pc(dict_num, key).move_to(pos_dict["sup_water"])
		elif key == "water_dps":
			if long_fake:
				neo_pc(dict_num, key).move_to(pos_dict["dps_light"])
			else:
				neo_pc(dict_num, key).move_to(pos_dict["dps_water"])
		elif key == "light_dps":
			if long_fake:
				neo_pc(dict_num, key).move_to(pos_dict["dps_water"])
			else:
				neo_pc(dict_num, key).move_to(pos_dict["dps_light"])
		elif key == "water_sup":
			if long_fake:
				neo_pc(dict_num, key).move_to(pos_dict["sup_light"])
			else:
				neo_pc(dict_num, key).move_to(pos_dict["sup_water"])
		elif key == "light_sup":
			if long_fake:
				neo_pc(dict_num, key).move_to(pos_dict["sup_water"])
			else:
				neo_pc(dict_num, key).move_to(pos_dict["sup_light"])


func move_tt_dodge():
	# West
	if mm_west_line != mm_thunder_fake:
		move_party_mm(P4Pos.TT_WEST_POS)
		neo_pc(1, "shriek_sup").move_to(P4Pos.TT_GAZE["nw"].rotated(deg_to_rad(mm_rotation_deg)))
		neo_pc(1, "shriek_dps").move_to(P4Pos.TT_GAZE["sw"].rotated(deg_to_rad(mm_rotation_deg)))
	# East
	else:
		move_party_mm(P4Pos.TT_EAST_POS)
		neo_pc(1, "shriek_sup").move_to(P4Pos.TT_GAZE["ne"].rotated(deg_to_rad(mm_rotation_deg)))
		neo_pc(1, "shriek_dps").move_to(P4Pos.TT_GAZE["se"].rotated(deg_to_rad(mm_rotation_deg)))


func move_center():
	move_party(P4Pos.CENTER_STACK_POS)


func inferno_dodge():
	if !inferno_fake:
		move_party(P4Pos.INFERNO_DODGE_POS)


func move_shriek_2_dodge():
	move_party(P4Pos.TT_WEST_POS)
	neo_pc(2, "shriek_sup").move_to(Vector2(0, 3))
	neo_pc(2, "shriek_dps").move_to(Vector2(0, -3))


func move_mr_dodge():
	if mm_ns_ice != (mm_ice_fake != mr_ice_fake):
		# NS Ice West Line
		if mm_west_line != (mm_thunder_fake != mr_thunder_fake):
			if tsunami_fake:
				move_party_mm(P4Pos.MM_NS_WEST_OUT_POS)
			else:
				move_party_mm(P4Pos.MM_NS_WEST_POS)
		# NS East
		else:
			if tsunami_fake:
				move_party_mm(P4Pos.MM_NS_EAST_OUT_POS)
			else:
				move_party_mm(P4Pos.MM_NS_EAST_POS)
	else:
		# EW West
		if mm_west_line != (mm_thunder_fake != mr_thunder_fake):
			if tsunami_fake:
				move_party_mm(P4Pos.MM_EW_WEST_OUT_POS)
			else:
				move_party_mm(P4Pos.MM_EW_WEST_POS)
		# EW East
		else:
			if tsunami_fake:
				move_party_mm(P4Pos.MM_EW_EAST_OUT_POS)
			else:
				move_party_mm(P4Pos.MM_EW_EAST_POS)


## END OF MOVEMENT


func move_party_mm(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key].rotated(deg_to_rad(mm_rotation_deg)))


func move_party(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key])
			


## HELPER FUNCTIONS

func order_debuffs():
	for key in party:
		party[key].order_debuffs(DEBUFF_ORDER)


func cast(spell_name: String, cast_time: float, caster: Node3D):
	target_cast_bar.cast(spell_name, cast_time, caster)
	enemy_cast_bar.cast(spell_name, cast_time)


func neo_pc(neo_num: int, neo_key: String) -> PlayableCharacter:
	if neo_num == 1:
		return party[party_neo_1_keys[neo_key]]
	elif neo_num == 2:
		return party[party_neo_2_keys[neo_key]]
	else:
		push_error("Invalid index in neo_pc.")
		return null


func check_if_facing(player: PlayableCharacter, pos: Vector3) -> bool:
	var facing_target := false
	var player_rotation := fposmod((rad_to_deg(player.get_model_rotation().y) + 180), 360.0)
	var angle_to_gaze_target = fposmod(rad_to_deg(v2(player.global_position).angle_to_point(v2(pos))) * -1 + 90, 360.0)
	if angle_to_gaze_target < GAZE_MIN_ANGLE:
		if player_rotation < angle_to_gaze_target + GAZE_MIN_ANGLE or player_rotation > GAZE_MAX_ANGLE + angle_to_gaze_target:
			facing_target = true
	elif angle_to_gaze_target > GAZE_MAX_ANGLE:
		if player_rotation > angle_to_gaze_target - GAZE_MIN_ANGLE or player_rotation < angle_to_gaze_target - GAZE_MAX_ANGLE:
			facing_target = true
	elif player_rotation > angle_to_gaze_target - GAZE_MIN_ANGLE and player_rotation < angle_to_gaze_target + GAZE_MIN_ANGLE:
		facing_target = true
	return facing_target


func on_toggle_bots_visible() -> void:
	var bots_visible = !Global.hide_bots
	for key in party:
		var pc: PlayableCharacter = party[key]
		if pc.is_player():
			continue
		pc.visible = bots_visible


# Swap values of given keys in dictionary
func dict_swap(dict: Dictionary, key_1, key_2):
	var temp = dict[key_1]
	dict[key_1] = dict[key_2]
	dict[key_2] = temp


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
