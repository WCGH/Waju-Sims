# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.


extends Node

enum Strat {KB}
enum StartPoint {START, FLOOD, CELEST, EXA, FORS}


## AoE Dimensions
# Ultima Repeater (Raidwide, visual only)
const REPEATER_RADIUS := 48.0
const REPEATER_LIFETIME := 0.2
const REPEATER_COLOR := Color(0.293, 0.463, 0.875, 0.669)
# Auto AoE
const AUTO_RADIUS := 12.0
const AUTO_LIFETIME := 0.4
const AUTO_COLOR := Color(0.61, 0.078, 0.847, 0.699)
# Flood - default starting position is SW safe
const F1_START_POS := Vector2(-58.531, -8.362)
const F1_TAR_POS := Vector2(-25.086, 25.086)
const F2_START_POS := Vector2(-25.085, -41.808)
const F2_TAR_POS := Vector2(8.362, -8.362)
const FLOOD_LENGTH := 94.6
const FLOOD_WIDTH := 23.65
const FLOOD_TELE_LIFETIME := 1.0
const FLOOD_TELE_COLOR := Color(0.651, 0.07, 0.07, 0.627)
const FLOOD_HIT_LIFETIME := 1.0
const FLOOD_HIT_COLOR := Color(0.407, 0.651, 0.941, 0.633)
const FLOOD_STACK_RADIUS := 12.0
const FLOOD_STACK_LIFETIME := 0.4
# Maddening Orchestra
const MAD_AOE_RADIUS := 10.0
const MAD_AOE_LIFETIME := 0.4
const MAD_AOE_COLOR := Color(0.0, 1.129, 1.116, 0.771)
const MAD_TANK_COLOR := Color(1.154, 0.823, 0.0, 0.843)
const SUPR_FLARE_RADIUS := 60.0
const SUPR_HOLY_RADIUS := 10.0
# Catastrophic Choice
const CHOICE_INNER_RADIUS := 23.0
const CHOICE_OUTTER_RADIUS := 48.0
const CHOICE_LIFETIME := 1.0
const EARTH_COLOR := Color(0.91, 0.518, 0.0, 0.82)
const WIND_COLOR := Color(0.387, 1.0, 0.514, 0.494)
# Entropy (post-Exaflare spreads)
const ENTROPY_RADIUS := 12.0
const ENTROPY_LIFETIME := 0.4
const ENTROPY_COLOR := Color(1.154, 0.823, 0.0, 0.843)
# Forsaken BH
const FORS_RADIUS := 20.0
const FORS_BAIT_RADIUS := 17.0
const FORS_TELE_LIFETIME := 5.0
const FORS_HIT_LIFETIME := 0.4
const FORS_TELE_COLOR := Color(0.595, 0.133, 0.305, 0.922)
const FORS_STACK_COLOR := Color(0.409, 0.068, 0.635, 0.892)

## Debuff Icon Scenes
const FIRE_RES_ICON = preload("uid://cmjhch4dhdaqo")
const ICE_RES_ICON = preload("uid://bmmswdj8pgu6f")
const LIGHTNING_RES_ICON = preload("uid://b50tautykfneq")
const SURPRISE_FLARE_ICON = preload("uid://b654u8vh6evx7")
const SURPRISE_HOLY_ICON = preload("uid://b5kkoprtmt4kw")
const CELEST_DEBUFF_DURATION := 20.0
const RES_ICONS := {"fire": FIRE_RES_ICON, "ice": ICE_RES_ICON, "light": LIGHTNING_RES_ICON}
const RES_ICON_NAMES = {"fire": "fire_res", "ice": "ice_res", "light": "lightning_res"}

const FORSAKEN_BH_SCENE = preload("uid://c62i12l6aug0r")
const NON_TANK_KEYS := ["h1", "h2", "m1", "m2", "r1", "r2"]
const MAD_SCOOT_DIST := 5.0
const CELEST_SCOOT_DIST := 4.0
const _RS1 := Vector2(0.3, 0.2)

@onready var target_controller: TargetController = %TargetController
@onready var gac: GroundAoeController = %GroundAoEController
@onready var exaflare_controller: DMUExaflareController = %DMUExaflareController
@onready var kefka: P5Kefka = %Kefka
@onready var lockon_controller: LockonController = %LockonController
@onready var encounter_menu: CanvasLayer = %EncounterMenu
@onready var p5_seq_anim: AnimationPlayer = %P5SeqAnim
@onready var target_cast_bar: TargetCastBar = %TargetCastBar
@onready var enemy_cast_bar: EnemyCastBar = %EnemyCastBar
@onready var celest_towers: CelestTowers = %CelestTowers
@onready var fail_list: FailList = %FailList
@onready var special_markers: Node3D = %SpecialMarkers
@onready var earth_rings: Node3D = %EarthRings
@onready var wind_rings: Node3D = %WindRings

var party: Dictionary[String, PlayableCharacter]
var flood_rota_factor: float
var flood_rotation_deg: float
var mad_keys := ["h1", "h2", "m1", "m2", "r1", "r2"]   # 0,1,2 take first aoe's
var tank_keys = ["t1", "t2"]   # flare, holy
var party_keys_celest: Dictionary
var earth_choice: bool
var fors_bh_outter_pos := [Vector2(-32, -32), Vector2(32, -32), Vector2(-32, 32), Vector2(32, 32)]
var fors_bh_inner_pos := [Vector2(0, -32), Vector2(32, 0), Vector2(-32, 0), Vector2(0, 32)]
var fors_bait_pos := [Vector2(0, 21), Vector2(-15, 15), Vector2(-15, -15), Vector2(15, -15)]
var inner_b_pos = Vector2(32, 0)
var is_b_covered := false
var stack_tar_key: String
var starting_point: StartPoint


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	gac.preload_aoe(["line", "circle", "donut"])
	exaflare_controller.preload_resources()
	target_controller.add_targetable_npc(kefka)
	lockon_controller.pre_load([LockonController.STACK_MARKER])
	## Get Strat and variables.
	#strat = DmuSavedVariables.save_data["settings"]["p5_strat"]
	starting_point = DmuSavedVariables.get_data_and_check_int("settings", "p5_start_point", 0, StartPoint.size()) as StartPoint
	instantiate_party(new_party)
	on_toggle_bots_visible()
	encounter_menu.toggle_bots_visible.connect(on_toggle_bots_visible)
	## Start animation sequence
	match starting_point:
		StartPoint.FLOOD:
			p5_seq_anim.play_section("p5_seq", 15.0)
		StartPoint.CELEST:
			p5_seq_anim.play_section("p5_seq", 52.0)
		StartPoint.EXA:
			p5_seq_anim.play_section("p5_seq", 96.3)
		StartPoint.FORS:
			p5_seq_anim.play_section("p5_seq", 147.3)
		_:
			p5_seq_anim.play("p5_seq")


func instantiate_party(new_party: Dictionary):
	party = new_party
	# RNG
	flood_rotation_deg = randi_range(0, 3) * 90.0
	flood_rota_factor = 1.0 if randi() % 2 == 0 else -1.0
	# Celestriad debuffs
	var celest_keys = party.keys()
	celest_keys.shuffle()
	party_keys_celest = {"fire1": celest_keys[0], "fire2": celest_keys[1], "ice1": celest_keys[2], "ice2": celest_keys[3],
		"light1": celest_keys[4], "light2": celest_keys[5], "none1": celest_keys[6], "none2": celest_keys[7]}



## ==========================START OF TIMELINE================================== 


# 0:01 - Cast Ultima Repeater (4.7s)
func cast_repeater():
	kefka_cast("Ultima Repeater", 4.7)


# 0:05.7 - Raidwide visual, no effect
func repeater_visual():
	gac.spawn_circle(Vector2.ZERO, REPEATER_RADIUS, REPEATER_LIFETIME, REPEATER_COLOR)


# 0:11.0 - Auto hit 1
# 0:14.2 - Auto hit 2
# 0:17.3 - Auto hit 3
func auto_hit():
	var tank_key = Global.TANK_ROLE_KEYS.pick_random()
	gac.spawn_circle(v2(party[tank_key].global_position), AUTO_RADIUS, AUTO_LIFETIME, AUTO_COLOR, [2, 2, "Fel Forces (Tank Auto)"])
	var healer_key = Global.HEALER_ROLE_KEYS.pick_random()
	gac.spawn_circle(v2(party[healer_key].global_position), AUTO_RADIUS, AUTO_LIFETIME, AUTO_COLOR, [2, 2, "Fel Forces (Healer Auto)"])
	var dps_key = Global.DPS_ROLE_KEYS.pick_random()
	gac.spawn_circle(v2(party[dps_key].global_position), AUTO_RADIUS, AUTO_LIFETIME, AUTO_COLOR, [4, 4, "Fel Forces (DPS Auto)"])


func auto_hit_pre_flood():
	if starting_point == StartPoint.FLOOD:
		return
	auto_hit()


# 0:17.6 - Cast Flood (5.9s)
func cast_flood():
	kefka_cast("Flood", 5.4)


# 0:17.8 - Flood 1 telegraph
# 0:18.8 - Flood 2 telegraph
# 0:19.8 - Flood 3 telegraph
# 0:20.8 - Flood 4 telegraph
func flood_tele(flood_index: int):
	var rota_deg = flood_rotation_deg + (flood_index * flood_rota_factor * 90.0)
	gac.spawn_line(F1_START_POS.rotated(deg_to_rad(rota_deg)), FLOOD_WIDTH, FLOOD_LENGTH,
		F1_TAR_POS.rotated(deg_to_rad(rota_deg)), FLOOD_TELE_LIFETIME, FLOOD_TELE_COLOR)
	gac.spawn_line(F2_START_POS.rotated(deg_to_rad(rota_deg)), FLOOD_WIDTH, FLOOD_LENGTH,
		F2_TAR_POS.rotated(deg_to_rad(rota_deg)), FLOOD_TELE_LIFETIME, FLOOD_TELE_COLOR)


# 0:23.8 - Flood 1 Hit
# 0:24.8 - Flood 2 Hit
# 0:25.8 - Flood 3 Hit
# 0:26.8 - Flood 4 Hit
func flood_hit(flood_index: int):
	var rota_deg = flood_rotation_deg + (flood_index * flood_rota_factor * 90.0)
	gac.spawn_line(F1_START_POS.rotated(deg_to_rad(rota_deg)), FLOOD_WIDTH, FLOOD_LENGTH,
		F1_TAR_POS.rotated(deg_to_rad(rota_deg)), FLOOD_HIT_LIFETIME, FLOOD_HIT_COLOR, [0, 0, "Flood"])
	gac.spawn_line(F2_START_POS.rotated(deg_to_rad(rota_deg)), FLOOD_WIDTH, FLOOD_LENGTH,
		F2_TAR_POS.rotated(deg_to_rad(rota_deg)), FLOOD_HIT_LIFETIME, FLOOD_HIT_COLOR, [0, 0, "Flood"])
	var flood_tar_key: String = party.keys().pick_random()
	gac.spawn_circle(v2(party[flood_tar_key].global_position), FLOOD_STACK_RADIUS, FLOOD_STACK_LIFETIME, FLOOD_HIT_COLOR, [8, 8, "Flood Stack"])
	

# 0:30.7 - Cast Maddening Orchestra (5.5s)
func cast_maddening():
	kefka_cast("Maddening Orchestra", 5.5)


# 0:36.5 - Mad hit 1 (Tank debuffs (6s) + 3 random)
func mad_hit_1():
	# Tank AoEs (MT = flare, OT = Holy)
	party[tank_keys[0]].add_debuff(SURPRISE_FLARE_ICON, 6.0, false, "surprise_flare")
	gac.spawn_circle(v2(party[tank_keys[0]].global_position), MAD_AOE_RADIUS, MAD_AOE_LIFETIME,
		MAD_TANK_COLOR, [1, 1, "Surprise Flare (Spread)"])
	party[tank_keys[1]].add_debuff(SURPRISE_HOLY_ICON, 6.0, false, "surprise_holy")
	gac.spawn_circle(v2(party[tank_keys[1]].global_position), MAD_AOE_RADIUS, MAD_AOE_LIFETIME,
		MAD_TANK_COLOR, [1, 1, "Surprise Holy (Spread)"])
	# Party AoEs (3 random targets)
	mad_keys.shuffle()
	for i in 3:
		var tar_pos = v2(party[mad_keys[i]].global_position)
		gac.spawn_circle(tar_pos, MAD_AOE_RADIUS, MAD_AOE_LIFETIME, MAD_AOE_COLOR, [1, 1, "Holy (Spread)"])


# 0:39.7 - Mad hit 2 (Proximity aoe's)
func mad_hit_2():
	var nearest = get_nearest_player_keys(Vector2.ZERO, 8)
	# Not sure if tank buster target is proximity based but shouldn't really matter.
	var tank_tar_key
	for key: String in nearest:
		if key.contains("t"):
			tank_tar_key = key
			break
	gac.spawn_circle(v2(party[tank_tar_key].global_position), MAD_AOE_RADIUS, MAD_AOE_LIFETIME,
		MAD_TANK_COLOR, [2, 2, "Holy (Tank Stack)", tank_keys])
	nearest.erase("t1")
	nearest.erase("t2")
	# Whitelist players who didn't take first Holy.
	var whitelist_keys = mad_keys.slice(3, 6)
	for i in 3:
		var tar_pos = v2(party[nearest[i]].global_position)
		gac.spawn_circle(tar_pos, MAD_AOE_RADIUS, MAD_AOE_LIFETIME, MAD_AOE_COLOR, [1, 1, "Holy (Spread)", whitelist_keys])


# 0:43.2 - Mad hit 3 (Tank debuffs expire)
func mad_hit_3():
	gac.spawn_circle(v2(party[tank_keys[0]].global_position), SUPR_FLARE_RADIUS, MAD_AOE_LIFETIME,
		MAD_TANK_COLOR, [2, 2, "Surprise Flare (MT)", tank_keys])
	gac.spawn_circle(v2(party[tank_keys[1]].global_position), SUPR_HOLY_RADIUS, MAD_AOE_LIFETIME,
		MAD_AOE_COLOR, [1, 1, "Surprise Holy (OT)", [party[tank_keys[1]]]])
	# Swap tank keys for next Maddening
	var tmp = tank_keys.pop_back()
	tank_keys.push_front(tmp)

# 0:47.9 - Auto hit 1
# 0:51.0 - Auto hit 2
# auto_hit()

# 0:52.4 - Cast Celestriad (4.7s)
func cast_celest():
	kefka_cast("Celestriad", 4.7)


# 0:57.5 - Assign Cele debuffs
func celest_debuffs():
	for celest_key: String in party_keys_celest:
		if celest_key.contains("fire"):
			party[party_keys_celest[celest_key]].add_debuff(FIRE_RES_ICON, CELEST_DEBUFF_DURATION, false, "fire_res")
		elif celest_key.contains("ice"):
			party[party_keys_celest[celest_key]].add_debuff(ICE_RES_ICON, CELEST_DEBUFF_DURATION, false, "ice_res")
		elif celest_key.contains("light"):
			party[party_keys_celest[celest_key]].add_debuff(LIGHTNING_RES_ICON, CELEST_DEBUFF_DURATION, false, "lightning_res")


# 0:57.8 - Show towers
func show_celest_towers():
	celest_towers.show_towers()


# 1:00.5 - Show tower glow
func activate_towers(set_index: int):
	celest_towers.activate_towers(set_index)


# 1:01.6 - Cast Catastrophic Choice (4.7s)
func cast_catastrophic():
	kefka_cast("Catastrophic Choice", 4.7)
	earth_choice = randi() % 2 == 0
	if earth_choice:
		earth_rings.play_ring_anim()
	else:
		wind_rings.play_ring_anim()

# 1:06.7 - Tower 1 hit + choice + swap glow
# 1:13.0 - Tower 2 hit + swap glow
# 1:13.8 - Cast Catastrophic Choice (4.7s)
# 1:19.3 - Towers 3 hit + choice + swap glow
func tower_hit(set_index: int):
	assert(set_index >= 0 and set_index < 3)
	# Check tower soaks
	var debuff_keys := ["fire", "ice", "light", "none"]
	for debuff_key in debuff_keys:
		# The tower returned is based off the initial assigned debuffs.
		var tower: CLTower
		if debuff_key == "none":
			tower = celest_towers.get_double_tower_cw()
			#bodies = celest_towers.get_double_tower_cw().get_bodies()
		else:
			tower = celest_towers.get_first_tower_soak_cw(debuff_key, set_index)
			#bodies = celest_towers.get_first_tower_soak_cw(debuff_key, set_index).get_bodies()
		var bodies: Array = tower.get_bodies()
		var tower_element: String = tower.get_tower_element()
		if bodies.size() > 2:
			fail_list.add_fail("Too many players soaked tower.")
		elif bodies.size() < 2:
			fail_list.add_fail("Not enough players soaked tower.")
		for body: PlayableCharacter in bodies:
			# Add new debuff
			body.add_debuff(RES_ICONS[tower_element], CELEST_DEBUFF_DURATION, false, RES_ICON_NAMES[tower_element])
			# Only need to check player, remove for testing purposese
			#if !body.is_player():
				#continue
			var body_celest_key: String = party_keys_celest.find_key(body.get_role())
			if !body_celest_key.contains(debuff_key):
				fail_list.add_fail("%s soaked wrong tower." % body.get_role_name())
	# If set 1 or 3, Choice hits
	if set_index != 1:
		if earth_choice:
			gac.spawn_circle(Vector2.ZERO, CHOICE_INNER_RADIUS, CHOICE_LIFETIME,
				EARTH_COLOR, [0, 0, "Catastrophic Choice (Earth)"])
		else:
			gac.spawn_donut(Vector2.ZERO, CHOICE_INNER_RADIUS, CHOICE_OUTTER_RADIUS,
				CHOICE_LIFETIME, WIND_COLOR, [0, 0, "Catastrophic Choice (Wind)"])
	# Swap glow after sets 1 and 2. Removes glow for after set 3.
	celest_towers.activate_towers(set_index + 1)


# 1:21.6 - Hide towers
func hide_towers():
	celest_towers.hide_towers()

# 1:22.9 - Cast Ultima Repeater (4.7)
# 1:27.6 - Raidwide telegraph
# 1:33.0 - Auto 1
# 1:36.1 - Auto 2

# 1:37.5 - Start Exawaves, Cast Stray Apocalypse (3.6s)
func start_exawaves():
	kefka_cast("Stray Apocalypse", 3.6)
	exaflare_controller.start_exaflares()
	
# 1:53.7 - Cast Stray Entropy (4.7s)
func cast_entropy():
	kefka_cast("Strat Entropy", 4.7)


# 1:58.4 - Entropy Spreads hit
func entropy_hit():
	for key in party:
		gac.spawn_circle(v2(party[key].global_position), ENTROPY_RADIUS, ENTROPY_LIFETIME,
			ENTROPY_COLOR, [1, 1, "Stray Entropy (Spread)", [party[key]]])


# 2:02.8 - Cast Maddening Orchestra (5.5s)
# 2:08.7 - Mad hit 1
# 2:11.9 - Mad hit 2 (prox)
# 2:15.4 - Mad hit 3
# 2:20.0 - Auto 1
# 2:23.1 - Auto 2
# 2:26.2 - Auto 3


# 2:27.6 - Cast Forsaken (9.7s)
func cast_forsaken():
	kefka_cast("Forsaken", 9.7)


# 2:38.0 - Forsaken 1 (2 telegraphs (center + outter) + stack marker + bait south)
func fors_1_tele():
	# BH Telegraphs
	gac.spawn_circle(Vector2.ZERO, FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	fors_bh_outter_pos.shuffle()
	fors_bh_inner_pos.shuffle()
	gac.spawn_circle(fors_bh_outter_pos.back(), FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	# Bait tele (assume we are baiting South)
	gac.spawn_circle(fors_bait_pos[0], FORS_BAIT_RADIUS, FORS_TELE_LIFETIME, MAD_TANK_COLOR)
	# Stack marker
	stack_tar_key = party.keys().pick_random() 
	lockon_controller.add_marker(LockonController.STACK_MARKER, party[stack_tar_key])


# 2:43.0 - Forsaken 1 hit (south bait hit + stack hit + spawn center + outter bh)
func fors_1_hit():
	# BH Spawn
	var pos = fors_bh_outter_pos.pop_back()
	var bh1: Node3D = FORSAKEN_BH_SCENE.instantiate()
	var bh2: Node3D = FORSAKEN_BH_SCENE.instantiate()
	special_markers.add_child(bh1)
	special_markers.add_child(bh2)
	bh1.global_position = Vector3.ZERO
	bh2.global_position = v3(pos)
	# Bait hit
	gac.spawn_circle(fors_bait_pos[0], FORS_BAIT_RADIUS, FORS_HIT_LIFETIME, FORS_STACK_COLOR, [0, 0, "Forsaken (Bait)"])
	# Stack hit
	gac.spawn_circle(v2(party[stack_tar_key].global_position), FLOOD_STACK_RADIUS, FLOOD_STACK_LIFETIME,
		FORS_STACK_COLOR, [8, 8, "Forsaken Bonds (Stack)"])
	lockon_controller.remove_marker(LockonController.STACK_MARKER, party[stack_tar_key])


# 2:46.0 - Forsaken 2 (2 outter tele, stack + SW bait)
func fors_2_tele():
	# BH Telegraphs
	gac.spawn_circle(fors_bh_outter_pos[-1], FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	gac.spawn_circle(fors_bh_outter_pos[-2], FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	# Bait tele (assume we are baiting SW)
	gac.spawn_circle(fors_bait_pos[1], FORS_BAIT_RADIUS, FORS_TELE_LIFETIME, MAD_TANK_COLOR)
	# Stack marker
	stack_tar_key = party.keys().pick_random() 
	lockon_controller.add_marker(LockonController.STACK_MARKER, party[stack_tar_key])


# 2:51.0 - Forsaken 2 hit
func fors_2_hit():
	# BH Spawn
	var pos1 = fors_bh_outter_pos.pop_back()
	var pos2 = fors_bh_outter_pos.pop_back()
	var bh1: Node3D = FORSAKEN_BH_SCENE.instantiate()
	var bh2: Node3D = FORSAKEN_BH_SCENE.instantiate()
	special_markers.add_child(bh1)
	special_markers.add_child(bh2)
	bh1.global_position = v3(pos1)
	bh2.global_position = v3(pos2)
	# Bait hit
	gac.spawn_circle(fors_bait_pos[1], FORS_BAIT_RADIUS, FORS_HIT_LIFETIME, FORS_STACK_COLOR, [0, 0, "Forsaken (Bait)"])
	# Stack hit
	gac.spawn_circle(v2(party[stack_tar_key].global_position), FLOOD_STACK_RADIUS, FLOOD_STACK_LIFETIME,
		FORS_STACK_COLOR, [8, 8, "Forsaken Bonds (Stack)"])
	lockon_controller.remove_marker(LockonController.STACK_MARKER, party[stack_tar_key])


# 2:54.0 - Forsaken 3 (1 outter 1 inner tele, stack, NW bait)
func fors_3_tele():
	# BH Telegraphs
	gac.spawn_circle(fors_bh_outter_pos[-1], FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	gac.spawn_circle(fors_bh_inner_pos[-1], FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	# Bait tele (assume we are baiting NW)
	gac.spawn_circle(fors_bait_pos[2], FORS_BAIT_RADIUS, FORS_TELE_LIFETIME, MAD_TANK_COLOR)
	# Stack marker
	stack_tar_key = party.keys().pick_random() 
	lockon_controller.add_marker(LockonController.STACK_MARKER, party[stack_tar_key])


# 2:59.0 - Forsaken 3 hit
func fors_3_hit():
	# BH Spawn
	var pos_outter = fors_bh_outter_pos.pop_back()
	var pos_inner = fors_bh_inner_pos.pop_back()
	var bh1: Node3D = FORSAKEN_BH_SCENE.instantiate()
	var bh2: Node3D = FORSAKEN_BH_SCENE.instantiate()
	special_markers.add_child(bh1)
	special_markers.add_child(bh2)
	bh1.global_position = v3(pos_outter)
	bh2.global_position = v3(pos_inner)
	if pos_inner == inner_b_pos:
		is_b_covered = true
	# Bait hit
	gac.spawn_circle(fors_bait_pos[2], FORS_BAIT_RADIUS, FORS_HIT_LIFETIME, FORS_STACK_COLOR, [0, 0, "Forsaken (Bait)"])
	# Stack hit
	gac.spawn_circle(v2(party[stack_tar_key].global_position), FLOOD_STACK_RADIUS, FLOOD_STACK_LIFETIME,
		FORS_STACK_COLOR, [8, 8, "Forsaken Bonds (Stack)"])
	lockon_controller.remove_marker(LockonController.STACK_MARKER, party[stack_tar_key])


# 3:02.0 - Forsaken 4 tele (2 inner)
func fors_4_tele():
	# BH Telegraphs
	gac.spawn_circle(fors_bh_inner_pos[-1], FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	gac.spawn_circle(fors_bh_inner_pos[-2], FORS_RADIUS, FORS_TELE_LIFETIME, FORS_TELE_COLOR)
	# Bait tele (assume we are baiting NW)
	gac.spawn_circle(fors_bait_pos[3], FORS_BAIT_RADIUS, FORS_TELE_LIFETIME, MAD_TANK_COLOR)
	# Stack marker
	stack_tar_key = party.keys().pick_random() 
	lockon_controller.add_marker(LockonController.STACK_MARKER, party[stack_tar_key])


# 3:07.0 - Forseaken 4 hit
func fors_4_hit():
	# BH Spawn
	var pos1 = fors_bh_inner_pos.pop_back()
	var pos2 = fors_bh_inner_pos.pop_back()
	var bh1: Node3D = FORSAKEN_BH_SCENE.instantiate()
	var bh2: Node3D = FORSAKEN_BH_SCENE.instantiate()
	special_markers.add_child(bh1)
	special_markers.add_child(bh2)
	bh1.global_position = v3(pos1)
	bh2.global_position = v3(pos2)
	# Bait hit
	gac.spawn_circle(fors_bait_pos[3], FORS_BAIT_RADIUS, FORS_HIT_LIFETIME, FORS_STACK_COLOR, [0, 0, "Forsaken (Bait)"])
	# Stack hit
	gac.spawn_circle(v2(party[stack_tar_key].global_position), FLOOD_STACK_RADIUS, FLOOD_STACK_LIFETIME,
		FORS_STACK_COLOR, [8, 8, "Forsaken Bonds (Stack)"])
	lockon_controller.remove_marker(LockonController.STACK_MARKER, party[stack_tar_key])


## ===========================END OF TIMELINE===================================



## ============================BOT MOVEMENT=====================================


func move_auto_pos():
	move_party(P5Pos.AUTO_POS)


func move_flood_pos_1():
	move_party_and_rotate(P5Pos.FLOOD_SW, flood_rotation_deg)


func move_flood_pos_2():
	if flood_rota_factor == 1.0:   #  swap sign
		move_party_and_rotate(P5Pos.FLOOD_NW, flood_rotation_deg)
	else:
		move_party_and_rotate(P5Pos.FLOOD_SE, flood_rotation_deg)


func move_flood_pos_3():
	move_party_and_rotate(P5Pos.FLOOD_NE, flood_rotation_deg)


func move_flood_pos_4():
	if flood_rota_factor != 1.0:   #  swap sign
		move_party_and_rotate(P5Pos.FLOOD_NW, flood_rotation_deg)
	else:
		move_party_and_rotate(P5Pos.FLOOD_SE, flood_rotation_deg)


func move_mad_pre_pos():
	move_party(P5Pos.MAD_PRE_POS)


# After hit 1
func move_mad_1():
	# Move tanks
	move_party(P5Pos.MAD_2_TANK_POS)
	# Move hits out
	var hit_keys = mad_keys.slice(0, 3)
	for key in hit_keys:
		party[key].move_to(scoot_out(P5Pos.MAD_PRE_POS[key], MAD_SCOOT_DIST))
	var non_hit_keys = mad_keys.slice(3, 6)
	for key in non_hit_keys:
		party[key].move_to(scoot_in(P5Pos.MAD_PRE_POS[key], MAD_SCOOT_DIST))


# After hit 2, mt/flare tank out
func move_mad_2():
	party[tank_keys[0]].move_to(P5Pos.MAD_3_TANK_POS["mt"])
	party[tank_keys[1]].move_to(P5Pos.MAD_3_TANK_POS["ot"])
	move_party(P5Pos.MAD_3_PARTY_POS)


func move_celest(set_index: int):
	# Ice
	var cw_ice_pos: Vector2
	var cw_fire_pos: Vector2
	var cw_light_pos: Vector2
	var cw_double_pos: Vector2
	# Always scoot in for second set (no choice)
	if earth_choice and set_index != 1:
		cw_ice_pos = scoot_out(v2(celest_towers.get_first_tower_soak_cw("ice", set_index).global_position), CELEST_SCOOT_DIST)
		cw_fire_pos = scoot_out(v2(celest_towers.get_first_tower_soak_cw("fire", set_index).global_position), CELEST_SCOOT_DIST)
		cw_light_pos = scoot_out(v2(celest_towers.get_first_tower_soak_cw("light", set_index).global_position), CELEST_SCOOT_DIST)
		cw_double_pos = scoot_out(v2(celest_towers.get_double_tower_cw().global_position), CELEST_SCOOT_DIST)
	else:
		cw_ice_pos = scoot_in(v2(celest_towers.get_first_tower_soak_cw("ice", set_index).global_position), CELEST_SCOOT_DIST)
		cw_fire_pos = scoot_in(v2(celest_towers.get_first_tower_soak_cw("fire", set_index).global_position), CELEST_SCOOT_DIST)
		cw_light_pos = scoot_in(v2(celest_towers.get_first_tower_soak_cw("light", set_index).global_position), CELEST_SCOOT_DIST)
		cw_double_pos = scoot_in(v2(celest_towers.get_double_tower_cw().global_position), CELEST_SCOOT_DIST)
	var pos_dict := {
		"fire1": cw_fire_pos, "fire2":  cw_fire_pos + _RS1, "ice1": cw_ice_pos, "ice2": cw_ice_pos+ _RS1,
		"light1": cw_light_pos, "light2": cw_light_pos + _RS1, "none1": cw_double_pos, "none2": cw_double_pos + _RS1
	}
	move_strat_party(pos_dict, party_keys_celest)


func move_exawave_spread():
	move_party(P5Pos.EXA_SPREAD_POS)


func move_forsaken_pre():
	move_party(P5Pos.FORS_S_POS)


# Overmove a bit to avoid first bait.
func move_fors_1_over():
	move_party(P5Pos.FORS_SW_OVER_POS)


# Adjust back to second bait pos.
func move_fors_1():
	move_party(P5Pos.FORS_SW_POS)


func move_fors_2_inter():
	move_party(P5Pos.FORS_W_POS)


func move_fors_2():
	move_party(P5Pos.FORS_NW_POS)


func move_fors_3_inter():
	move_party(P5Pos.FORS_N_POS)
	

func move_fors_3():
	move_party(P5Pos.FORS_NE_POS)


func move_fors_4_inter():
	if is_b_covered:
		move_party(P5Pos.FORS_N_POS)
	else:
		move_party(P5Pos.FORS_E_POS)


func move_fors_4():
	if is_b_covered:
		move_party(P5Pos.FORS_NW_POS)
	else:
		move_party(P5Pos.FORS_SE_POS)


func move_party(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key])


func move_party_and_rotate(position_dict: Dictionary, rotation_deg: float):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key].rotated(deg_to_rad(rotation_deg)))


func move_strat_party(position_dict: Dictionary, role_keys_dict: Dictionary):
	for key in position_dict:
		if !role_keys_dict.has(key) or role_keys_dict[key] == null:
			continue
		party[role_keys_dict[key]].move_to(position_dict[key])

# Moves vector towards middle by dist
func scoot_in(pos: Vector2, dist: float):
	return pos - (pos.normalized() * dist)


func scoot_out(pos: Vector2, dist: float):
	return pos + (pos.normalized() * dist)


## ===========================END OF MOVEMENT===================================

## +++++++++++++++++++++++++++HELPER FUNCTIONS++++++++++++++++++++++++++++++++++


func kefka_cast(spell_name: String, cast_time: float):
	target_cast_bar.cast(spell_name, cast_time, kefka)
	enemy_cast_bar.cast(spell_name, cast_time)


func on_toggle_bots_visible() -> void:
	var bots_visible = !Global.hide_bots
	for key in party:
		var pc: PlayableCharacter = party[key]
		if pc.is_player():
			continue
		pc.visible = bots_visible


func get_nearest_player_keys(position: Vector2, count: int) -> Array:
	assert(count <= 8 and count > 0)
	var dist_list := []
	var keys_list := []
	for key in party:
		dist_list.append(v2(party[key].global_position).distance_squared_to(position))
		keys_list.append(key)
	# Manually sort parallel arrays
	assert(dist_list.size() == keys_list.size())
	var n = dist_list.size()
	for i in range(n):
		for j in range(0, n - i - 1):
			if dist_list[j] > dist_list[j + 1]:
				# Swap distance
				var tmp = dist_list[j]
				dist_list[j] = dist_list[j + 1]
				dist_list[j + 1] = tmp
				# Swap key
				var tmp_key = keys_list[j]
				keys_list[j] = keys_list[j + 1]
				keys_list[j + 1] = tmp_key
	# Truncate array down to given number.
	keys_list.resize(count)
	return keys_list


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
