# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# TODO: wind check at end, force debuff option, in-line buff first in order, scale kefka model

extends Node


# Preloaded scenes
const BIG_KEFKA_UID := "uid://ddmbbusmjpmqg"
const BLACK_HOLE_SET_UID := "uid://ddu02jcnuf02w"

enum Strat {KB}
enum StartPoint {DB1, BOA, LC, DB2, EQ, STOMP}

## AoE Dimensions
const T2_WAIT_DIST := 15.0     # Distance away from Exdeath that offtank will wait for Thunder hit.
const LATLONG_POSITION_ROTATION_DEG := 16.0  
const SLIDE_TIME := 0.6
# Thunder III Tank Buster
const THUNDER_TB_RADIUS := 10.0
const THUNDER_TB_LIFETIME := 0.5
const THUNDER_TB_COLOR := Color(0.247, 0.123, 0.54, 0.9)
# LatLong Cone
const LATLONG_CONE_ANGLE := 127.5
const LATLONG_CONE_LENGTH := 150.0
const LATLONG_CONE_LIFETIME := 0.5
const LATLONG_CONE_COLOR := Color(0.574, 0.402, 0.853, 0.759)
# Slap Happy
const LEFT_SLAP_POS := [Vector2(25, -25), Vector2(25, 0), Vector2(25, 25)]
const RIGHT_SLAP_POS := [Vector2(-25, -25), Vector2(-25, 0), Vector2(-25, 25)]
const CENTER_SLAP_POS := Vector2.ZERO
# Side Slap AoE
const SIDE_SLAP_RADIUS := 25.0
const SIDE_SLAP_LIFETIME := 0.4
const SIDE_SLAP_COLOR := Color(0.706, 0.737, 0.89, 0.6)
# Center Slap AoE
const SLAP_TELE_LIFETIME := 1.2
const CENTER_SLAP_RADIUS := 13.0
const CENTER_SLAP_LIFETIME := 0.4
const CENTER_SLAP_COLOR := Color(0.678, 0.647, 0.941, 0.8)
const TELEGRAPH_COLOR := Color(0.914, 0.549, 0.337, 0.7)
# Role Cones (same dimentions for party cone)
const ROLE_CONE_ANGLE := 80.0
const ROLE_CONE_LENGTH := 100.0
const ROLE_CONE_LIFETIME := 0.5
const ROLE_CONE_COLOR := Color(0.574, 0.402, 0.853, 0.759)
# Black Hole Laser
const BH_LASER_LENGTH := 100.0
const BH_LASER_WIDTH := 12.0
const BH_LASER_LIFETIME := 0.5
const BH_LASER_COLOR := Color(0.051, 0.156, 0.721, 0.9)
# Edict Cone
const EDICT_CONE_ANGLE := 179.9
const EDICT_CONE_LENGTH := 150.0
const EDICT_CONE_LIFETIME := 0.5
const EDICT_CONE_COLOR := Color(0.908, 0.221, 0.07, 0.585)
# Body Slam
const BODY_SLAM_POS := Vector2(0, -50)
const BODY_SLAM_LENGTH := 100.0
const BODY_SLAM_WIDTH := 35.0
const BODY_SLAM_LIFETIME := 0.8
const BODY_SLAM_COLOR := Color(0.908, 0.22, 0.074, 0.759)
# Blizzard AoE
const BLIZZARD_RADIUS := 12.0
const BLIZZARD_TELE_LIFETIME := 2.0
const BLIZZARD_LIFETIME := 0.4
const BLIZZARD_COLOR := Color(0.908, 0.22, 0.074, 0.759)
# Stomp Towers
const TOWER_RADIUS := 10.0
const TOWER_LIFETIME := 1.0
const TOWER_COLOR := Color(0.606, 0.265, 0.133, 0.271)
# Fire Stack
const FIRE_STACK_RADIUS := 12.0
const FIRE_STACK_LIFETIME := 0.4
const FIRE_STACK_COLOR := Color(0.639, 0.706, 0.839, 0.657)
# Big Bang AoE
const BIG_BANG_RADIUS := 12.0
const BIG_BANG_LIFETIME := 0.4
const BIG_BANG_COLOR := Color(0.611, 0.69, 0.945, 0.819)

# Position order NW CCW
const CHAOS_HEROS := ["t1", "h1", "m1", "m2"]
const EXDEATH_HEROS := ["t2", "h2", "r1", "r2"]
# Used prio to determine who is baiting wind pairs. Order is near > far from Chaos.
const BAIT_PRIO_SG := ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
#const BAIT_PRIO := ["h1", "h2", "t1", "t2", "r1", "r2", "m1", "m2"]
# Starting positions
const EXDEATH_START_POS := Vector3(10, 0 ,-20)
const CHAOS_START_POS := Vector3(-10, 0, -20)
const SMALL_KEFKA_POS := Vector3(0, -1, -21.6)
const LEFT_TOWER_POS := Vector2(-22, 0)
const RIGHT_TOWER_POS := Vector2(22, 0)
const BIG_KEFKA_POS := Vector3.ZERO
const BIG_KEFKA_ROTA := Vector3.ZERO

## Debuff Icon Scenes
const FATED_HERO_ICON = preload("uid://dtwamivy8wi0g")
const EPIC_HERO_ICON = preload("uid://cocoojxnowwh5")
const ACCRETION_ICON = preload("uid://bpoqhec4fvhh7")
const MEANEST_EXISTENCE_ICON = preload("uid://b5w70hvk58k0e")
const PRIMORDIAL_CRUST_ICON = preload("uid://dpp61r8cvxyyy")
const UNBECOMING_ICON = preload("uid://dqmxpam5xbc7i")
const FIL_ICON = preload("uid://dryfwy8vvtst0")
const SIL_ICON = preload("uid://cmm3xwp3b30xh")
const TIL_ICON = preload("uid://c66bvq5c4scl0")

@onready var lockon_controller: LockonController = %LockonController
@onready var target_cast_bar: TargetCastBar = %TargetCastBar
@onready var enemy_cast_bar: EnemyCastBar = %EnemyCastBar
@onready var target_controller: TargetController = %TargetController
@onready var chaos: MoveableBoss = %Chaos
@onready var exdeath: MoveableBoss = %Exdeath
@onready var gac: GroundAoeController = %GroundAoEController
@onready var kefka: Node3D = %Kefka
@onready var encounter_menu: CanvasLayer = %EncounterMenu
@onready var p3_eq_anim: AnimationPlayer = %P3EqAnim
@onready var fail_list: FailList = %FailList
@onready var tether_controller: TetherController = %TetherController


var party: Dictionary
var party_keys_eq: Dictionary = {
	"fil_dps": null, "sil_dps": null, "til_dps": null, "fil_acr": null,
	"fil_sup": null, "sil_sup": null, "til_sup": null, "sil_acr": null,
}
var tether_prio_kb := {
	[0, 1, 2, 3]: [0, 1, 2],
	[4, 5]: [2, 0, 1],
	[6, 7]: [1, 2, 0]
}
var tether_targets_kb := {
	1: {
		1: {1: "fil_dps"},
		2: {1: "fil_dps", 2: "fil_sup"}
	},
	2: {
		1: {1: "fil_dps", 2: "fil_sup", 3: "fil_acr"},
		2: {1: "sil_dps", 2: "fil_sup", 3: "fil_acr"},
		3: {1: "sil_dps", 2: "sil_sup", 3: "fil_acr"}
	},
	3: {
		1: {1: "sil_dps", 2: "sil_sup", 3: "sil_acr"},
		2: {1: "til_dps", 2: "sil_sup", 3: "sil_acr"},
		3: {1: "til_dps", 2: "til_sup", 3: "sil_acr"}
	},
	4: {
		1: {1: "til_dps", 2: "til_sup"},
		2: {1: "til_sup"}
	}
}
var strat: Strat
var arena_rotation_deg: float
var player_key: String
var big_kefka: BigKefka
var t1_chaos: bool
var lat_long: bool     # Warn: this is flipped compared to the in game cast name. true = side safe first. 
var chaos_tank: PlayableCharacter
var exdeath_tank: PlayableCharacter
var starting_point: StartPoint
var kefka_rotation_factor: float
var slap_left: bool
var bh_set: BlackHoleSet
var bh_set_scene: PackedScene
var bh_tether_order := [2, 1, 0]   # First set is S>E>N, last set is N>E>S
var bh_active := false
var damning_snapshot_pos: Vector3
var body_slam_rotated_pos: Vector2
var left_tower: TowerAoe
var right_tower: TowerAoe
var dps_fire: bool
var fire_key: String
var bh_set_number
var knockdown_hit_pos: Array


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	gac.preload_aoe(["line", "circle", "cone"])
	ResourceLoader.load_threaded_request(BIG_KEFKA_UID)
	ResourceLoader.load_threaded_request(BLACK_HOLE_SET_UID)
	target_controller.add_targetable_npc(chaos)
	target_controller.add_targetable_npc(exdeath)
	GameEvents.bh_body_entered.connect(_on_bh_entered)
	lockon_controller.pre_load([LockonController.STACK_MARKER])
	tether_controller.preload_resources(true)
	player_key = Global.player_role_key
	## Get Strat and variables.
	#strat = DmuSavedVariables.save_data["settings"]["p3_eq_strat"]
	starting_point = DmuSavedVariables.get_data_and_check_int("settings", "p3_boa_start_point", 0, StartPoint.size()) as StartPoint
	t1_chaos = DmuSavedVariables.get_data_and_check_bool("settings", "p3_boa_t1_chaos")
	instantiate_party(new_party)
	on_toggle_bots_visible()
	encounter_menu.toggle_bots_visible.connect(on_toggle_bots_visible)
	# Move bosses if we're starting here.
	if starting_point >= StartPoint.DB2:
		exdeath.global_position = EXDEATH_START_POS
		chaos.global_position = CHAOS_START_POS
	
	## Start animation sequence	
	match starting_point:
		StartPoint.EQ:
			p3_eq_anim.play_section("p3_eq", 20)
		StartPoint.STOMP:
			kefka.hide()
			p3_eq_anim.play_section("p3_eq", 150)  # 150
		_:
			p3_eq_anim.play("p3_eq")


func instantiate_party(new_party):
	party = new_party
	# RNG for arena and party setup
	#arena_rotation_deg = randi_range(0, 3) * 90.0
	kefka_rotation_factor = randi_range(0, 7)
	lat_long = randi() % 2 == 0
	dps_fire  = randi() % 2 == 0
	fire_key = Global.DPS_ROLE_KEYS.pick_random() if dps_fire else Global.SUP_ROLE_KEYS.pick_random()
	# Set up party dict
	var dps_keys = Global.DPS_ROLE_KEYS.duplicate()
	dps_keys.shuffle()
	party_keys_eq["fil_dps"] = dps_keys.pop_back()
	party_keys_eq["sil_dps"] = dps_keys.pop_back()
	party_keys_eq["til_dps"] = dps_keys.pop_back()
	var sup_keys = Global.SUP_ROLE_KEYS.duplicate()
	var healer_acr = sup_keys.pop_at(randi_range(2, 3))
	sup_keys.shuffle()
	party_keys_eq["fil_sup"] = sup_keys.pop_back()
	party_keys_eq["sil_sup"] = sup_keys.pop_back()
	party_keys_eq["til_sup"] = sup_keys.pop_back()
	if randi() % 2 == 0:
		party_keys_eq["fil_acr"] = dps_keys.pop_back()
		party_keys_eq["sil_acr"] = healer_acr
	else:
		party_keys_eq["sil_acr"] = dps_keys.pop_back()
		party_keys_eq["fil_acr"] = healer_acr
	# These will swap after first Thunder III hit if Invuln Thunder is not selected.
	if t1_chaos:
		chaos_tank = party["t1"]
		exdeath_tank = party["t2"]
	else:
		chaos_tank = party ["t2"]
		exdeath_tank = party["t1"]



## START OF TIMELINE

# 0:00 move DB2 pos
func move_db2_pos():
	for key in CHAOS_HEROS:
		party[key].move_to(v2(party[key].global_position) + (v2(party[key].global_position).direction_to(v2(chaos.global_position)) *\
			(v2(party[key].global_position).distance_to((v2(chaos.global_position))) - 6.0)))
	for key in EXDEATH_HEROS:
		party[key].move_to(v2(party[key].global_position) + (v2(party[key].global_position).direction_to(v2(exdeath.global_position)) *\
			(v2(party[key].global_position).distance_to((v2(exdeath.global_position))) - 6.0)))

# 0:01 Cast Decisive Battle (2.5s)
func cast_decisive_1():
	exdeath.plant()
	chaos.plant()
	cast("The Decisive Battle", 2.5, chaos)
	cast("The Decisive Battle", 2.5, exdeath)

# 0:03.5 assign DB debuffs
func decisive_finish():
	# Anim
	chaos.get_model().cast_generic()
	exdeath.get_model().cast_generic()
	# Assign epic/fated debuffs
	var epic_targets := get_nearest_player_bodies(v2(chaos.global_position), 4)
	var fated_targets := get_nearest_player_bodies(v2(exdeath.global_position), 4)
	for target in epic_targets:
		party[target].add_debuff(EPIC_HERO_ICON, 0.0, false, "epic_hero")
	for target in fated_targets:
		party[target].add_debuff(FATED_HERO_ICON, 0.0, false, "fated_hero")

# 0:06.0 Set bosses follow
func set_bosses_follow():
	chaos.follow_target(chaos_tank)
	exdeath.follow_target(exdeath_tank)

# Move Thunder pos. Move thunder exdeath tank under exdeath
func move_thunder_1_pos():
	var exdeath_tank_pos = v2(exdeath.global_position) + (v2(exdeath.global_position).normalized() * 3.0)
	var chaos_tank_pos = v2(chaos_tank.global_position) + (v2(chaos_tank.global_position).direction_to(v2(exdeath.global_position)) *\
		(v2(chaos_tank.global_position).distance_to(v2(exdeath.global_position)) - T2_WAIT_DIST))
	exdeath_tank.move_to(exdeath_tank_pos)
	chaos_tank.move_to(chaos_tank_pos)
	# Move rest of party center
	move_party(BoAPos.CENTER_POS)

# 0:08.2 Cast Thunder III (4.7s), show small kefka
# Plant Exdeath, cast Thunder III (AoE)
func cast_thunder_tb():
	exdeath.plant()
	cast("Thunder III", 4.7, exdeath)

func show_small_kefka():
	# Fade in small Kefka for rp
	kefka.global_position = SMALL_KEFKA_POS
	kefka.look_at(Vector3.UP, Vector3.UP, true)
	kefka.play_stand_idle()

# 0:13.0s and 16.0s
func thunder_tb_hit():
	var nearest = get_nearest_player_bodies(v2(exdeath.global_position), 1)
	gac.spawn_circle(v2(party[nearest.back()].global_position), THUNDER_TB_RADIUS,
		THUNDER_TB_LIFETIME, THUNDER_TB_COLOR, [1, 1, "Thunder III (Tank Buster)", [party[nearest.back()]]])

# Swap tanks
func move_thunder_1_pos_2():
	exdeath_tank.move_to(Vector2.ZERO)
	chaos_tank.move_to(v2(exdeath.global_position))

# 0:10.3 Cast Max (4.5s) - Kefka
func cast_max():
	enemy_cast_bar.cast("Max", 4.5)

# Move pre-eq pos. Tanks center boss
func move_center_bosses():
	exdeath_tank.move_to(v2(exdeath.global_position).normalized() * -9.8)
	chaos_tank.move_to(v2(chaos.global_position).normalized() * -12.5)

func move_center():
	move_party(EqPos.CENTER_POS)

# 0:13.1 Cast Earthquake (4.7s) - Chaos
func cast_eq():
	chaos.plant()
	cast("Earthquake", 4.7, chaos)

# 0:17.0
func exdeath_follow():
	exdeath.follow_target(exdeath_tank)

# 0:17.8
func chaos_cast_anim():
	chaos.get_model().cast_generic()

# 0:20.5 assign Eq debuffs
func assign_eq_debuffs():
	if starting_point == StartPoint.EQ:
		set_bosses_follow()
	for key: String in party_keys_eq:
		if key.contains("fil"):
			get_eq_pc(key).add_debuff(FIL_ICON, 0.0, false, "lc1")
			get_eq_pc(key).add_debuff(PRIMORDIAL_CRUST_ICON, 70.0, false, "primoridal_crust")
		elif key.contains("sil"):
			get_eq_pc(key).add_debuff(SIL_ICON, 0.0, false, "lc2")
			get_eq_pc(key).add_debuff(PRIMORDIAL_CRUST_ICON, 105.0, false, "primoridal_crust")
		elif key.contains("til"):
			get_eq_pc(key).add_debuff(TIL_ICON, 0.0, false, "lc3")
			get_eq_pc(key).add_debuff(PRIMORDIAL_CRUST_ICON, 140.0, false, "primoridal_crust")
		if key.contains("acr"):
			get_eq_pc(key).add_debuff(ACCRETION_ICON, 13.0, false, "accretion")
	# Hide small kefka
	kefka.play_fade_out()

func move_eq_conga():
	move_strat_party(EqPos.EQ_CONGA_POS_KB, party_keys_eq)


# 0:27.0 show big kefka
func spawn_big_kefka():
	var scene: PackedScene = ResourceLoader.load_threaded_get(BIG_KEFKA_UID)
	big_kefka = scene.instantiate()
	get_tree().get_first_node_in_group("enemies_layer").add_child(big_kefka)
	big_kefka.rotation_degrees.y = kefka_rotation_factor * 45.0
	big_kefka.show()
	big_kefka.play_fade_in()

# 0:29.0 Cast Slap Happy (4.2), raise hand
func cast_slap_happy():
	enemy_cast_bar.cast("Slap Happy", 4.2)
	slap_left = randi() % 2 == 0
	if slap_left:
		big_kefka.play_raise_left()
	else:
		big_kefka.play_raise_right()

# Move slap dodge 1
func move_slap_dodge():
	if slap_left:
		move_party_and_rotate(EqPos.LEFT_SLAP_POS, kefka_rotation_factor * -45.0)
	else:
		move_party_and_rotate(EqPos.RIGHT_SLAP_POS, kefka_rotation_factor * -45.0)


# 0:33.2 slap animation start
func slap_anim_start():
	if slap_left:
		big_kefka.play_left_smash()
	else:
		big_kefka.play_right_smash()

# 0:34.0 slap hit 1
func slap_hit(hit_index: int):
	var hit_pos: Vector2 = LEFT_SLAP_POS[hit_index] if slap_left else RIGHT_SLAP_POS[hit_index]
	hit_pos = hit_pos.rotated(deg_to_rad(kefka_rotation_factor * -45.0))
	gac.spawn_circle(hit_pos, SIDE_SLAP_RADIUS, SIDE_SLAP_LIFETIME, SIDE_SLAP_COLOR, [0, 0, "Slap Happy"])
	# On third hit, show center tele
	if hit_index == 2:
		gac.spawn_circle(CENTER_SLAP_POS, CENTER_SLAP_RADIUS, SLAP_TELE_LIFETIME, TELEGRAPH_COLOR)
		

# 0:34.2 Cast Black Hole (2.8s) - Exdeath
func cast_black_hole():
	exdeath.plant()
	cast("Black Hole", 2.8, exdeath)

# 0:34.8 slap hit 2
## slap_hit(hit_number: int)

# 0:35.6 slap hit 3, show center hit telegraph
## slap_hit(hit_number: int)

# 0:36.6 slap center hit with cones
func center_slap_hit():
	gac.spawn_circle(Vector2.ZERO, CENTER_SLAP_RADIUS, CENTER_SLAP_LIFETIME, CENTER_SLAP_COLOR, [0, 0, "Slap Happy (Center AoE)"])
	# Slap left = role cones
	if slap_left:
		var targets = []
		targets.append(party[Global.DPS_ROLE_KEYS.pick_random()])
		targets.append(party[Global.TANK_ROLE_KEYS.pick_random()])
		targets.append(party[Global.HEALER_ROLE_KEYS.pick_random()])
		gac.spawn_cone(Vector2.ZERO, ROLE_CONE_ANGLE, ROLE_CONE_LENGTH, v2(targets[0].global_position),
			ROLE_CONE_LIFETIME, ROLE_CONE_COLOR, [4, 4, "Slap Happy (DPS Cone)"])
		gac.spawn_cone(Vector2.ZERO, ROLE_CONE_ANGLE, ROLE_CONE_LENGTH, v2(targets[1].global_position),
			ROLE_CONE_LIFETIME, ROLE_CONE_COLOR, [2, 2, "Slap Happy (Tank Cone)"])
		gac.spawn_cone(Vector2.ZERO, ROLE_CONE_ANGLE, ROLE_CONE_LENGTH, v2(targets[2].global_position),
			ROLE_CONE_LIFETIME, ROLE_CONE_COLOR, [2, 2, "Slap Happy (Healer Cone)"])
	# Party cone
	else:
		var key = party.keys().pick_random()
		gac.spawn_cone(Vector2.ZERO, ROLE_CONE_ANGLE, ROLE_CONE_LENGTH, v2(party[key].global_position),
			ROLE_CONE_LIFETIME, ROLE_CONE_COLOR, [8, 8, "Slap Happy (Group Stack)"])

# 37.6 show black hole set 1 + tether 1
func show_bh_set(set_number: int):
	bh_set_number = set_number
	arena_rotation_deg = randi_range(0, 3) * 90.0
	if !bh_set_scene:
		bh_set_scene = ResourceLoader.load_threaded_get(BLACK_HOLE_SET_UID)
	if !bh_set:
		bh_set = bh_set_scene.instantiate()
		get_tree().get_first_node_in_group("ground_marker_layer").add_child(bh_set)
	bh_active = true
	bh_set.rotation_degrees.y = -arena_rotation_deg
	bh_set.show_bh_set(set_number)
	#bh_tether_order.shuffle()
	if set_number == 4:
		bh_tether_order = [0, 1, 2]
	# Spawn tethers
	spawn_tether(1)
	if set_number > 1:
		spawn_tether(2)
		if set_number < 4:
			spawn_tether(3)




func spawn_tether(tether_num: int):
	var tar_key = party.keys().pick_random()
	var bh_source = bh_set.get_bh_node(bh_tether_order[tether_num - 1])
	tether_controller.spawn_tether(bh_source, party[tar_key], Color.BLACK, Color.BLACK, 0.0, 0.1, true)


func despawn_tether(tether_num: int):
	if !bh_set:
		return
	tether_controller.remove_tether(bh_set.get_bh_node(bh_tether_order[tether_num - 1]))


func move_bh_pre_pos(tether_set_num: int):
	var active_tethers = bh_tether_order.duplicate()
	# Narrow down which tethers are active
	if bh_set_number == 1:
		if tether_set_num == 1:
			active_tethers = active_tethers.slice(0, 1)
		else:
			active_tethers = active_tethers.slice(1, 3)
	elif bh_set_number == 4:
		if tether_set_num == 1:
			active_tethers = active_tethers.slice(0, 2)
		else:
			active_tethers = active_tethers.slice(2, 3)
	# Order tether by Kefka relative prio
	order_tether_prio_kb(active_tethers)
	for tether_num in tether_targets_kb[bh_set_number][tether_set_num]:
		var pc: PlayableCharacter = party[party_keys_eq[tether_targets_kb[bh_set_number][tether_set_num][tether_num]]]
		pc.move_to(EqPos.BH_PRE_POS[active_tethers[tether_num - 1]].rotated(deg_to_rad(arena_rotation_deg)))


func move_bh_bait_pos(tether_set_num: int):
	var active_tethers = bh_tether_order.duplicate()
	# Narrow down which tethers are active
	if bh_set_number == 1:
		if tether_set_num == 1:
			active_tethers = active_tethers.slice(0, 1)
		else:
			active_tethers = active_tethers.slice(1, 3)
	elif bh_set_number == 4:
		if tether_set_num == 1:
			active_tethers = active_tethers.slice(0, 2)
		else:
			active_tethers = active_tethers.slice(2, 3)
	# Order tether by Kefka relative prio
	order_tether_prio_kb(active_tethers)
	for tether_num in tether_targets_kb[bh_set_number][tether_set_num]:
		var pc: PlayableCharacter = party[party_keys_eq[tether_targets_kb[bh_set_number][tether_set_num][tether_num]]]
		pc.move_to(EqPos.BH_BAIT_POS[active_tethers[tether_num - 1]].rotated(deg_to_rad(arena_rotation_deg)))


# 41.0 Force tether onto bot targets
func force_tether_target(tether_set_num: int):
	var active_tethers = bh_tether_order.duplicate()
	# Narrow down which tethers are active
	if bh_set_number == 1:
		if tether_set_num == 1:
			active_tethers = active_tethers.slice(0, 1)
		else:
			active_tethers = active_tethers.slice(1, 3)
	elif bh_set_number == 4:
		if tether_set_num == 1:
			active_tethers = active_tethers.slice(0, 2)
		else:
			active_tethers = active_tethers.slice(2, 3)
	# Order tether by Kefka relative prio
	order_tether_prio_kb(active_tethers)
	for tether_num in tether_targets_kb[bh_set_number][tether_set_num]:
		var bh_source = bh_set.get_bh_node(active_tethers[tether_num - 1])
		var tar = tether_controller.get_tether_target(bh_source)
		if tar.is_player() and !Global.spectate_mode:
			return
		var new_tar = party[party_keys_eq[tether_targets_kb[bh_set_number][tether_set_num][tether_num]]]
		tether_controller.set_tether_target(bh_source, new_tar)


# Orders array of direction index clockwise from Kefka using tether_prio dictionary.
func order_tether_prio_kb(active_tethers: Array):
	var ordered_tethers
	# Adjust rotation factor for arena rotation
	var rota_factor: int = (int(kefka_rotation_factor) + int(arena_rotation_deg / 45)) % 8
	for key_arr in tether_prio_kb:
		if key_arr.has(rota_factor):
			ordered_tethers = tether_prio_kb[key_arr]
	order_lr_prio(ordered_tethers, active_tethers)

# 44.2 show tether 2/3
## spawn_tether(2):
## spawn_tether(3):

# 44.6 tether 1 hit
func tether_hit(tether_num: int):
	if !bh_set:
		return
	var bh_source = bh_set.get_bh_node(bh_tether_order[tether_num - 1])
	var target = tether_controller.get_tether_target(bh_source)
	gac.spawn_line(v2(bh_source.global_position), BH_LASER_WIDTH, BH_LASER_LENGTH, v2(target.global_position),
		BH_LASER_LIFETIME, BH_LASER_COLOR, [1, 1, "Nothingness (Black Hole Laser)", [target]])
	# For simplicity, we'll just assume 1 person gets hit for debuff checks
	if target.has_debuff("meanest_existence"):
		if target.has_debuff("primordial_crust"):
			target.remove_debuff("primordial_crust")
			target.remove_debuff("meanest_existence")
		else:
			fail_list.add_fail("%s took too many hits of Nothingness (Black Hole Tether)." % target.get_role_name())
		return
	if target.has_debuff("unbecoming"):
		target.remove_debuff("unbecoming")
		target.add_debuff(MEANEST_EXISTENCE_ICON, 0.0, false, "meanest_existence")
	else:
		target.add_debuff(UNBECOMING_ICON, 0.0, true, "unbecoming")


# Need to position Exdeath here. If T2 is a tether, that movement should override this. 
func move_thunder_2_pre_pos():
	exdeath_tank.move_to(Vector2(-9, -22).rotated(deg_to_rad(arena_rotation_deg)))

# 49.6 Cast Thunder III (4.7s)
## cast_thunder_tb()

# 52.6 tether 2/3 hit, fade out black hole set
## tether_hit(2)
## tether_hit(3)
func hide_bh_set():
	if !bh_set:
		return
	bh_set.hide_bh_set()
	bh_active = false

func move_thunder_2_pos_1():
	var exdeath_tank_pos = v2(exdeath.global_position) + (v2(exdeath.global_position).normalized() * 3.0)
	var chaos_tank_pos = v2(chaos_tank.global_position) + (v2(chaos_tank.global_position).direction_to(v2(exdeath.global_position)) *\
		(v2(chaos_tank.global_position).distance_to(v2(exdeath.global_position)) - T2_WAIT_DIST))
	exdeath_tank.move_to(exdeath_tank_pos)
	chaos_tank.move_to(chaos_tank_pos)


# 54.3 Thunder hit 1
## thunder_tb_hit


func move_thunder_2_pos_2():
	exdeath_tank.move_to(Vector2.ZERO)
	chaos_tank.move_to(v2(exdeath.global_position) + (v2(exdeath.global_position).normalized() * 2.0))


# 55.0 Kefka fade out
func big_kefka_fade_out():
	big_kefka.play_fade_out()

# 57 Kefka fade in
func move_kefka_fade_in():
	kefka_rotation_factor = randi_range(0, 7)
	big_kefka.rotation_degrees.y = kefka_rotation_factor * 45.0
	big_kefka.play_fade_in()

# 57.3 Thunder hit 2
## thunder_tb_hit
# TODO: unplant exdeath

# 57.8 Cast Damning Edict (4.6s), face towards random, save snapshot, anim
func cast_damning():
	chaos.plant()
	chaos.get_model().play_edict_start()
	cast("Damning Edict", 4.6, chaos)
	var rand_key = party.keys().pick_random()
	damning_snapshot_pos = party[rand_key].global_position
	chaos.look_at(damning_snapshot_pos)
	chaos.rotation.x = 0.0
	chaos.rotation.z = 0.0
	# TODO: anim?
	
# 59.0 Cast Slap Happy (4.2), raise hand
## cast_slap_happy()
## exdeath_follow()

# Move behind Chaos
func move_edict_dodge():
	var facing_vector = chaos.get_global_transform().basis
	for key in party:
		party[key].move_to(v2((facing_vector.z * 4.0) + chaos.global_position))

# 1:02.5 Edict anim
func edict_anim():
	chaos.get_model().play_edict_finish()

# 1:03? Edict hit
func edict_hit():
	gac.spawn_cone(v2(chaos.global_position), EDICT_CONE_ANGLE, EDICT_CONE_LENGTH,
		v2(damning_snapshot_pos), EDICT_CONE_LIFETIME, EDICT_CONE_COLOR, [0, 0, "Damning Edict"])


# 1:03.2 slam anim start
## slap_anim_start()

# 1:04.0 slap hit 1
## slap_hit()
# 1:04.8 slap hit 2
## slap_hit()
# 1:05.6 slap hit 3
## slap_hit()
# 1:06.6 slap hit center
## center_slap_hit()

func chaos_follow():
	chaos.follow_target(chaos_tank)

# 1:08.2 black hole set 2 + tethers 4/5/6 show
## show_bh_set(2)
# 1:15.2 laser 1 (4/5/6) hit 
## tether_hit()

# Chaos stops auto's here, but he still rotates towards target.
#func plant_chaos():
	#chaos.plant()

# 1:20.2 laser 2 hit
## tether_hit()
# 1:22.0 Kefka fade out
## big_kefka_fade_out()
# 1:24.0 Kefka fade in
## big_kefka_fade_in()
# 1:25.2 laser 3 hit, fade out black hole set, cast Damning Edict 2 (4.6s), face towards random, etc.
## tether_hit()
## hide_bh_set()
## cast_damning()

# 1:26.4 Cast Look Upon Me And Depsair (4.7s)
func cast_look():
	enemy_cast_bar.cast("Look Upon Me And Despair", 4.7)

func move_edict_slam_dodge():
	# Get chaos rotation relative to Kefka North
	#var chaos_rota = ((int(chaos.rotation_degrees.y) % 360) - (int(kefka_rotation_factor) * 45)) % 360
	# var temp = chaos.rotation_degrees.y
	var chaos_rota = fposmod(fposmod(chaos.rotation_degrees.y, 360.0) - (kefka_rotation_factor * 45.0), 360.0)
	var safe_pos: Vector2
	if chaos_rota >= 0 and chaos_rota <= 45:
		safe_pos = EqPos.EDICT_SLAM_DODGE_POS["se"]
	elif chaos_rota > 45 and chaos_rota <= 135:
		safe_pos = EqPos.EDICT_SLAM_DODGE_POS["e"]
	elif chaos_rota > 135 and chaos_rota <= 180:
		safe_pos = EqPos.EDICT_SLAM_DODGE_POS["ne"]
	elif chaos_rota > 180 and chaos_rota <= 225:
		safe_pos = EqPos.EDICT_SLAM_DODGE_POS["nw"]
	elif chaos_rota > 225 and chaos_rota <= 315:
		safe_pos = EqPos.EDICT_SLAM_DODGE_POS["w"]
	elif chaos_rota > 315 and chaos_rota < 360:
		safe_pos = EqPos.EDICT_SLAM_DODGE_POS["sw"]
	for key in party:
		party[key].move_to(safe_pos.rotated(deg_to_rad(kefka_rotation_factor * -45.0)))
	
# 1:29.8 Edict anim
## edict_anim()
# 1:30.3 Edict hit
## edict_hit()
# 1:30.9 Thunder III Cast (4.7s)
## cast_thunder_tb()

## Body Slam 1

# ?? Body slam 1 anim + telegraph
func body_slam_anim():
	big_kefka.play_body_slam()
# 1:30.6 Body slam  tele
func body_slam_tele():
	body_slam_rotated_pos = BODY_SLAM_POS.rotated(deg_to_rad(kefka_rotation_factor * -45.0))   # If backwards, rotate -45.0
	gac.spawn_line(body_slam_rotated_pos, BODY_SLAM_WIDTH, BODY_SLAM_LENGTH, Vector2.ZERO, 0.5, TELEGRAPH_COLOR)
# 1:31.1 Body slam hit
func body_slam_hit():
	# TIL gets a pass on fail check because bot does not dodge body slam while dealing with final laser.
	gac.spawn_line(body_slam_rotated_pos, BODY_SLAM_WIDTH, BODY_SLAM_LENGTH, Vector2.ZERO,
		BODY_SLAM_LIFETIME, BODY_SLAM_COLOR, [0, 1, "Body Slam", [party[party_keys_eq["til_sup"]]]])

# 1:33.1 Body slam post anim
func post_body_slam_anim():
	big_kefka.play_idle()
## chaos_follow()

# 1:35.6, 1:38.6
## thunder_hit()

# 1:40
## exdeath_follow()

# 1:42.3 show black hole set 3 + tethers 7/8/9
## show_bh_set(3)
# 1:49.3 laser 1 hit (7/8/9)
## tether_hit()
# 1:54.3 laser 2 hit
## tether_hit()
# 1:59.3 laser 3 hit
## tether_hit()

# Face Chaos 45 deg from Kefka
func move_pre_lat_long():
	chaos_tank.move_to(Vector2(8.5, -8.5).rotated(deg_to_rad(kefka_rotation_factor * -45.0)))

# 2:05.8 Cast Long/Lat (5.4s), White Hole (5.4s)
func cast_latlong():
	chaos.plant()
	chaos.get_model().start_lat_long()
	if lat_long:
		cast("Latitudinal Implosion", 5.4, chaos)
	else:
		cast("Longitudinal Implosion", 5.4, chaos)

func cast_white_hole():
	exdeath.plant()
	cast("White Hole", 5.4, exdeath)

# 2:07.0 Cast Slap Happy (4.2s), raise hand
## cast_slap_happy()

func move_lat_long_1():
	if lat_long:
		if slap_left:
			move_party_and_rotate(EqPos.LAT_LEFT_POS, kefka_rotation_factor * -45.0)
		else:
			move_party_and_rotate(EqPos.LAT_RIGHT_POS, kefka_rotation_factor * -45.0)
	else:
		if slap_left:
			move_party_and_rotate(EqPos.LONG_LEFT_POS, kefka_rotation_factor * -45.0)
		else:
			move_party_and_rotate(EqPos.LONG_RIGHT_POS, kefka_rotation_factor * -45.0)

func move_lat_long_2():
	if lat_long:
		if slap_left:
			move_party_and_rotate(EqPos.LONG_LEFT_POS, kefka_rotation_factor * -45.0)
		else:
			move_party_and_rotate(EqPos.LONG_RIGHT_POS, kefka_rotation_factor * -45.0)
	else:
		if slap_left:
			move_party_and_rotate(EqPos.LAT_LEFT_POS, kefka_rotation_factor * -45.0)
		else:
			move_party_and_rotate(EqPos.LAT_RIGHT_POS, kefka_rotation_factor * -45.0)

# ?? latlong anim start
func lat_long_finish_anim():
	if lat_long:
		chaos.get_model().finish_lat_long()
	else:
		chaos.get_model().finish_long_lat()

# 2:11:2 latlong hit 1
func lat_long_hit_1():
	var facing_vector = chaos.get_global_transform().basis
	# Latitudinal Implosion (sides first)
	if lat_long:
		#var left_vector = facing_vector.x
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH,
			v2(facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])
	# Longitudinal Implosion (front/back first)
	else:
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(facing_vector.z + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.z + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])

# ?? latlong hit 2
func lat_long_hit_2():
	var facing_vector = chaos.get_global_transform().basis
	# Longitudinal Implosion (sides second)
	if !lat_long:
		#var left_vector = facing_vector.x
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH,
			v2(facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])
	# Latitudinal Implosion (front/back second)
	else:
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(facing_vector.z + chaos.global_position ), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.z + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])

# 2:11.2 slap anim
## slap_anim_start()
# 2:12.0 slap hit 1
## slap_hit(1)
# 2:12.8 slap hit 2
## slap_hit(2)
# 2:13.6 slap hit 3
## slap_hit(3)
# 2:14.6 slap hit center
## center_slap_hit()
## chaos_follow()
# 2:15.8 show black hole set 4 + tether 10/11
## show_bh_set(4)
# 2:22.8 tether 10/11 hit, show tether 12
## tether_hit(1/2)
## spawn_tether(3)
# 2:24.4 Cast Look Upon Me And Despair (4.7s)
## cast_look()

func move_final_slam_pos():
	for key in party:
		if key == party_keys_eq["til_sup"]:
			continue
		party[key].move_to(Vector2(22, 0).rotated(deg_to_rad(kefka_rotation_factor * -45.0)))
	var bh_source = bh_set.get_bh_node(bh_tether_order[2])
	var pos = v2(bh_source.global_position).rotated(deg_to_rad(7.0))
	party[party_keys_eq["til_sup"]].move_to(pos)

# 2:28.5 start body slam anim
## body_slam_anim()
# 2:28.6 show body slam telegraph
## body_slam_tele()
# 2:29.1 body slam hit (can snapshot a bit earlier). Kefka 
## body_slam_hit()
# ~2:29.8 tether 12 hit (laser 3)
## tether_hit(3)

# 2:30.0 Check if we cleansed all primordial crust debuffs
func check_primordial_crust():
	for key in party:
		if party[key].has_debuff("primordial_crust"):
			fail_list.add_fail("%s did not cleanse Primordial Crust." % party[key].get_role_name())

# 2:31.7 Kefka stand up anim (to float)
func kefka_float_anim():
	if !big_kefka:
		spawn_big_kefka()
	big_kefka.play_float_idle()


func move_stack_center():
	move_party(EqPos.CENTER_STACK_POS)


# 2:35.8 Cast Blizzard III (2.6s)
func cast_blizzard():
	exdeath.plant()
	cast("Blizzard III", 2.6, exdeath)

# 2:37.7 Cast Stomp-A-Mole (4.7s)
func cast_stomp():
	enemy_cast_bar.cast("Stomp-A-Mole", 4.7)

# 2:39.0 Drop blizzard puddles 1, show stack marker
func blizzard_puddles():
	# Spawn telegraphs
	for key in party:
		gac.spawn_circle(v2(party[key].global_position), BLIZZARD_RADIUS, BLIZZARD_TELE_LIFETIME, TELEGRAPH_COLOR)

func show_stack_marker():
	lockon_controller.add_marker(LockonController.STACK_MARKER, party[fire_key])

# 2:39.2 Cast Knock Down (4.7s)
func cast_knock_down():
	chaos.plant()
	cast("Knock Down", 4.7, chaos)

# Move to pairs with Kefka relative North
func move_blizzard_1():
	move_party_and_rotate(EqPos.BLIZZARD_PAIRS_POS, kefka_rotation_factor * -45.0)


func move_blizzard_2():
	if dps_fire:
		move_party_and_rotate(EqPos.SUP_TOWER_POS, kefka_rotation_factor * -45.0)
	else:
		move_party_and_rotate(EqPos.DPS_TOWER_POS, kefka_rotation_factor * -45.0)


func move_blizzard_3():
	if !dps_fire:
		move_party_and_rotate(EqPos.SUP_TOWER_POS, kefka_rotation_factor * -45.0)
	else:
		move_party_and_rotate(EqPos.DPS_TOWER_POS, kefka_rotation_factor * -45.0)

# 2:42.0 Drop Blizzard puddles 2
## blizzard_puddles()
## exdeath_follow()

# 2:42.2 Fade in tower 1
func show_left_tower():
	var pos = LEFT_TOWER_POS.rotated(deg_to_rad(kefka_rotation_factor * -45.0))
	left_tower = gac.spawn_tower_2(pos, TOWER_RADIUS, TOWER_LIFETIME, TOWER_COLOR)

# 2:44.0 Start stomp anim
func stomp_anim():
	big_kefka.play_stomp()

# 2:44.7 Tower 1 hit, Fade in tower 2
func left_tower_hit():
	var bodies = left_tower.get_collisions()
	if bodies.size() > 2:
		fail_list.add_fail("Too many players soaked left tower.")
	if bodies.size() < 2:
		fail_list.add_fail("Too few players soaked left tower.")

func show_right_tower():
	var pos = RIGHT_TOWER_POS.rotated(deg_to_rad(kefka_rotation_factor * -45.0))
	right_tower = gac.spawn_tower_2(pos, TOWER_RADIUS, TOWER_LIFETIME, TOWER_COLOR)

# 2:45.0 Fire stack 1 hit
func fire_1_stack_hit():
	fire_stack_hit()
	fire_key = Global.SUP_ROLE_KEYS.pick_random() if dps_fire else Global.DPS_ROLE_KEYS.pick_random()
	lockon_controller.add_marker(LockonController.STACK_MARKER, party[fire_key])

# 2:45.7 Tower 2 hitFade in tower 3
func right_tower_hit():
	var bodies = right_tower.get_collisions()
	if bodies.size() > 2:
		fail_list.add_fail("Too many players soaked right tower.")
	if bodies.size() < 2:
		fail_list.add_fail("Too few players soaked right tower.")

## show_left_tower()

# 2:46.7 Tower 3 hit, fade in tower 4
## left_tower_hit()
## show_right_tower()
## chaos_follow()

# 2:47.7 Tower 4 hit
## right_tower_hit()

# 2:49.0 Kefka fade out
#func big_kefka_fade_out_float():
	#big_kefka.play_fade_out_float()

# 2:49.1 Cast Blizzard III (3.7s)
func cast_blizzard_long():
	exdeath.plant()
	cast("Blizzard III", 3.7, exdeath)

# 2:49.6 Cast Big Bang (4.5s)
func cast_big_bang():
	chaos.plant()
	cast("Big Bang", 4.5, chaos)

# 2:49.8 Fire 2 Stack hit
func fire_stack_hit():
	var pos = v2(party[fire_key].global_position)
	knockdown_hit_pos.append(pos)
	gac.spawn_circle(pos, FIRE_STACK_RADIUS, FIRE_STACK_LIFETIME, FIRE_STACK_COLOR, [4, 4, "Knock Down (LP Stack)"])
	lockon_controller.remove_marker(LockonController.STACK_MARKER, party[fire_key])

# 2:52.8
func blizzard_long_hit():
	# Big bang AoE's
	for pos in knockdown_hit_pos:
		gac.spawn_circle(pos, BIG_BANG_RADIUS, BIG_BANG_LIFETIME, BIG_BANG_COLOR, [0, 0, "Big Bang"])
	# Check if player is moving
	if party[player_key].velocity.length_squared() < 1.0:
			fail_list.add_fail("Player failed to move during Blizzard.")
	
## END OF TIMELINE


# TODO: need to handle hidden/inactive set still having active area trigger.
func _on_bh_entered(_body: PlayableCharacter):
	#if !bh_active:
		#return
	#var role_name = StringName("Player") if body.is_player() else body.get_role_name()
	#fail_list.add_fail("%s was hit by Black Hole." % role_name)
	pass

func get_eq_pc(eq_key: String) -> PlayableCharacter:
	return party[party_keys_eq[eq_key]]


# Make sure the keys in both Dictionaries match.
#func move_strat_party_rtd(position_dict: Dictionary, role_keys_dict: Dictionary):
	#for key in position_dict:
		#if !role_keys_dict.has(key) or role_keys_dict[key] == null:
			#continue
		#party[role_keys_dict[key]].move_to(position_dict[key].rotated(deg_to_rad(arena_rotation_deg)))


func move_strat_party(position_dict: Dictionary, role_keys_dict: Dictionary):
	for key in position_dict:
		if !role_keys_dict.has(key) or role_keys_dict[key] == null:
			continue
		party[role_keys_dict[key]].move_to(position_dict[key])


#func move_strat_party_and_rotate(position_dict: Dictionary, role_keys_dict: Dictionary, rotation: float):
	#for key in position_dict:
		#if !role_keys_dict.has(key) or role_keys_dict[key] == null:
			#continue
		#party[role_keys_dict[key]].move_to(position_dict[key].rotated(deg_to_rad(rotation)))


#func move_party_rtd(position_dict: Dictionary):
	#for key in party:
		#if position_dict.has(key):
			#party[key].move_to(position_dict[key].rotated(deg_to_rad(arena_rotation_deg)))


func move_party(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key])


func move_party_and_rotate(position_dict: Dictionary, rotation_deg: float):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key].rotated(deg_to_rad(rotation_deg)))


func cast(spell_name: String, cast_time: float, caster: Node3D):
	target_cast_bar.cast(spell_name, cast_time, caster)
	enemy_cast_bar.cast(spell_name, cast_time)


## HELPER FUNCTIONS

# Used for mirror along Wind crystal axis
#func flip_neg_xy(pos: Vector2) -> Vector2:
	#return Vector2(-pos.y, -pos.x)


# Returns array containing given number of nearest player keys to given position (v2)
func get_nearest_player_bodies(position: Vector2, count: int) -> Array:
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


func on_toggle_bots_visible() -> void:
	var bots_visible = !Global.hide_bots
	for key in party:
		var pc: PlayableCharacter = party[key]
		if pc.is_player():
			continue
		pc.visible = bots_visible


# Orders the keys by given prio
func order_lr_prio(ordered_keys: Array, keys_to_be_sorted: Array):
	keys_to_be_sorted.sort_custom(func(a, b): return ordered_keys.find(a) < ordered_keys.find(b))

func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
