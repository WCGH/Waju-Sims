# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# TODO: P2 only player baits clones. wind check at end, force debuff option


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
# LC Line AoE
#const LC_LINE_START_POS := Vector2(0, -48.0)
#const LC_LINE_TARGET := Vector2.ZERO
#const LC_LINE_LIFETIME := 1.5
#const LC_LINE_WIDTH := 27.0
#const LC_LINE_LENGTH := 96.0
#const LC_LINE_COLOR := Color(0.686, 0.265, 0.913, 0.181)

# Position order NW CCW
const CHAOS_HEROS := ["t1", "h1", "m1", "m2"]
const EXDEATH_HEROS := ["t2", "h2", "r1", "r2"]
# Used prio to determine who is baiting wind pairs. Order is near > far from Chaos.
const BAIT_PRIO_SG := ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
#const BAIT_PRIO := ["h1", "h2", "t1", "t2", "r1", "r2", "m1", "m2"]

## Debuff Icon Scenes
const ACCRETION_ICON = preload("uid://bpoqhec4fvhh7")
const MEANEST_EXISTENCE_ICON = preload("uid://b5w70hvk58k0e")
const PRIMORDIAL_CRUST_ICON = preload("uid://dpp61r8cvxyyy")
const UNBECOMING_ICON = preload("uid://dqmxpam5xbc7i")
const FIL_ICON = preload("uid://dryfwy8vvtst0")
const SIL_ICON = preload("uid://cmm3xwp3b30xh")
const TIL_ICON = preload("uid://c66bvq5c4scl0")

#@onready var lockon_controller: LockonController = %LockonController
#@onready var fail_list: FailList = %FailList
@onready var target_cast_bar: TargetCastBar = %TargetCastBar
@onready var enemy_cast_bar: EnemyCastBar = %EnemyCastBar
@onready var target_controller: TargetController = %TargetController
@onready var chaos: MoveableBoss = %Chaos
@onready var exdeath: MoveableBoss = %Exdeath
@onready var gac: GroundAoeController = %GroundAoEController
@onready var kefka: Node3D = %Kefka
@onready var encounter_menu: CanvasLayer = %EncounterMenu
@onready var p3_eq_anim: AnimationPlayer = %P3EqAnim

var party: Dictionary
var party_boa: Dictionary = {
	"short_dps": null, "long_dps": null, "short_sup": null, "long_sup": null,
	"wind_sup_near": null, "wind_sup_far": null, "wind_dps_near": null, "wind_dps_far": null
}
var 
var strat: Strat
var arena_rotation_deg: float
var t1_chaos: bool
var lat_long: bool     # Warn: this is flipped compared to the in game cast name. true = side safe first. 
var chaos_tank: PlayableCharacter
var exdeath_tank: PlayableCharacter
var starting_point: StartPoint


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	gac.preload_aoe(["line", "circle", "cone"])
	ResourceLoader.load_threaded_request(BIG_KEFKA_UID)
	ResourceLoader.load_threaded_request(BLACK_HOLE_SET_UID)
	target_controller.add_targetable_npc(chaos)
	target_controller.add_targetable_npc(exdeath)
	#lockon_controller.pre_load()
	
	## Get Strat and variables.
	#strat = DmuSavedVariables.save_data["settings"]["p3_eq_strat"]
	starting_point = DmuSavedVariables.get_data_and_check_int("settings", "p3_boa_start_point", 0, StartPoint.size()) as StartPoint
	t1_chaos = DmuSavedVariables.get_data_and_check_bool("settings", "p3_boa_t1_chaos")
	instantiate_party(new_party)
	on_toggle_bots_visible()
	encounter_menu.toggle_bots_visible.connect(on_toggle_bots_visible)
	## Start animation sequence	
	match starting_point:
		StartPoint.EQ:
			p3_eq_anim.play_section("p3_boa", 16, 110)
		StartPoint.STOMP:
			p3_eq_anim.play_section("p3_boa", 75, 110)
		_:
			p3_eq_anim.play("p3_boa")


func instantiate_party(new_party):
	party = new_party
	# RNG for arena and party setup
	arena_rotation_deg = randi_range(0, 3) * 90.0
	lc_rotation_deg = randi_range(0, 7) * 45.0
	lc_direction_factor = 1.0 if randi() % 2 == 0 else -1.0  # 1 = CCW, -1 = CW
	player_tailwind = randi() % 2 == 0
	fire_left = randi() % 2 == 0
	fire_short = randi() % 2 == 0
	lat_long = randi() % 2 == 0
	# Set up water/fire debuffs
	if fire_short:
		short_debuff_params = {"scene" : ENTROPY_ICON, "duration" : SHORT_DEBUFF_DURATION, "name" : "entropy"}
		long_debuff_params = {"scene" : DYNAMIC_FLUID_ICON, "duration" : LONG_DEBUFF_DURATION, "name" : "dynamic_fluid"}
	else:
		short_debuff_params = {"scene" : DYNAMIC_FLUID_ICON, "duration" : SHORT_DEBUFF_DURATION, "name" : "dynamic_fluid"}
		long_debuff_params = {"scene" : ENTROPY_ICON, "duration" : LONG_DEBUFF_DURATION, "name" : "entropy"}
	# Set up party dict
	var dps_keys = Global.DPS_ROLE_KEYS.duplicate()
	dps_keys.shuffle()
	party_boa["short_dps"] = dps_keys.pop_back()
	party_boa["long_dps"] = dps_keys.pop_back()
	var sup_keys = Global.SUP_ROLE_KEYS.duplicate()
	sup_keys.shuffle()
	party_boa["short_sup"] = sup_keys.pop_back()
	party_boa["long_sup"] = sup_keys.pop_back()
	# Remaining keys are winds, order by who is baiting (far > near).
	order_lr_prio(BAIT_PRIO_SG, sup_keys)
	order_lr_prio(BAIT_PRIO_SG, dps_keys)
	party_boa["wind_dps_far"] = dps_keys[1]
	party_boa["wind_dps_near"] = dps_keys[0]
	party_boa["wind_sup_far"] = sup_keys[1]
	party_boa["wind_sup_near"] = sup_keys[0]
	# These will swap after first Thunder III hit if Invuln Thunder is not selected.
	if t1_chaos:
		chaos_tank = party["t1"]
		exdeath_tank = party["t2"]
	else:
		chaos_tank = party ["t2"]
		exdeath_tank = party["t1"]
	chaos.plant()
	exdeath.plant()



## START OF TIMELINE


























## 7:25 = 0:02
# Cast Decisive Battle
## Move to decisive positions
func cast_decisive():
	cast("The Decisive Battle", 2.6, chaos)
	cast("The Decisive Battle", 2.6, exdeath)


func move_pre_pos():
	move_party(BoAPos.DECISIVE_POS_SG)

# Assign debuffs to 4 nearest to each. Finish anim
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

# Set bosses to follow
func set_bosses_follow():
	chaos.follow_target(chaos_tank)
	exdeath.follow_target(exdeath_tank)

# TODO: Move to pre boa pos
func move_pre_boa():
	move_party(BoAPos.POST_DECISIVE_TANK_POS_SG)


# Plant Chaos, cast Bowels of Agony
func cast_boa():
	chaos.plant()
	cast("Bowels of Agony", 4.7, chaos)

# Finish anim, spawn shapes, assign debuffs
func boa_finish():
	chaos.get_model().cast_generic()
	# Assign Entropy/Fluid
	party[party_boa["short_dps"]].add_debuff(short_debuff_params["scene"], 
		short_debuff_params["duration"], false, short_debuff_params["name"])
	party[party_boa["short_sup"]].add_debuff(short_debuff_params["scene"], 
		short_debuff_params["duration"], false, short_debuff_params["name"])
	party[party_boa["long_dps"]].add_debuff(long_debuff_params["scene"], 
		long_debuff_params["duration"], false, long_debuff_params["name"])
	party[party_boa["long_sup"]].add_debuff(long_debuff_params["scene"], 
		long_debuff_params["duration"], false, long_debuff_params["name"])
	# Assign Head/Tailwind
	for key in party:
		if party[key].is_player():
			if player_tailwind:
				party[key].add_debuff(TAILWIND_ICON, HEADWIND_DURATION, false, "tailwind")
			else:
				party[key].add_debuff(HEADWIND_ICON, HEADWIND_DURATION, false, "headwind")
		# Give random Head/Tailwind, this won't get checked so we don't need to store it.
		else:
			if randi() % 2 == 0:
				party[key].add_debuff(TAILWIND_ICON, HEADWIND_DURATION, false, "tailwind")
			else:
				party[key].add_debuff(HEADWIND_ICON, HEADWIND_DURATION, false, "headwind")
	# Show shapes
	fire_triangle.show()
	wind_diamond.show()
	water_circle.show()

# Set Chaos to follow
func set_chaos_follow():
	chaos.follow_target(chaos_tank)
	exdeath.follow_target(exdeath_tank)

# 
func move_tank_thunder_bait():
	# Flip arena if either short water or fire right, but not both
	if fire_left != fire_short:
		move_party_rtd_mirrored(BoAPos.PRE_FIRE_TANK_POS_1_SG)
	else:
		move_party_rtd(BoAPos.PRE_FIRE_TANK_POS_1_SG)


func move_tank_thunder_bait_2():
	if fire_left != fire_short:
		move_party_rtd_mirrored(BoAPos.PRE_FIRE_TANK_POS_2_SG)
	else:
		move_party_rtd(BoAPos.PRE_FIRE_TANK_POS_2_SG)


## Move to first pos
func move_short_debuff_pos():
	if fire_short:
		if fire_left:
			move_strat_party_rtd(BoAPos.SHORT_FIRE_POS_SG, party_boa)
		else:
			move_strat_party_rtd_mirrored(BoAPos.SHORT_FIRE_POS_SG, party_boa)
	else:
		if fire_left:
			move_strat_party_rtd(BoAPos.SHORT_WATER_POS_SG, party_boa)
		else:
			move_strat_party_rtd_mirrored(BoAPos.SHORT_WATER_POS_SG, party_boa)



# Plant Exdeath, cast Thunder III (AoE)
func cast_thunder_aoe():
	exdeath.plant()
	cast("Thunder III", 6.7, exdeath)
	# Remove Decisive Battle debuffs
	for key in party:
		party[key].remove_debuff("epic_hero")
		party[key].remove_debuff("fated_hero")


# Trigger first set of debuffs + Thunder AoE
func short_debuff_hit():
	# Thunder III hit
	gac.spawn_circle(v2(exdeath.global_position), THUNDER_AOE_RADIUS,
		THUNDER_AOE_LIFETIME, THUNDER_AOE_COLOR, [0, 0, "Thunder III (AoE)"])
	# Short debuffs hit
	if fire_short:
		gac.spawn_circle(v2(party[party_boa["short_dps"]].global_position),
			ENTROPY_RADIUS, ENTROPY_LIFETIME, ENTROPY_COLOR, [1, 1, "Entropy Spread", [party[party_boa["short_dps"]]]])
		gac.spawn_circle(v2(party[party_boa["short_sup"]].global_position),
			ENTROPY_RADIUS, ENTROPY_LIFETIME, ENTROPY_COLOR, [1, 1, "Entropy Spread", [party[party_boa["short_sup"]]]])
	else:
		gac.spawn_donut(v2(party[party_boa["short_dps"]].global_position),
			DYNAMIC_INNER, DYNAMIC_OUTTER, DYNAMIC_LIFETIME, DYNAMIC_COLOR, [0, 0, "Dynamic Fluid Spread", [party[party_boa["short_dps"]]]])
		gac.spawn_donut(v2(party[party_boa["short_sup"]].global_position),
			DYNAMIC_INNER, DYNAMIC_OUTTER, DYNAMIC_LIFETIME, DYNAMIC_COLOR, [0, 0, "Dynamic Fluid Spread", [party[party_boa["short_sup"]]]])

# Trigger shapes
func first_shapes_hit():
	# Handle shapes trigger. We assume that the correct number of debuffs went off.
	# Fire Crystal
	if fire_short:
		var players_hit := get_nearest_player_bodies(v2(fire_triangle.global_position), 2)
		for key in players_hit:
			var fire_donut = gac.spawn_donut(v2(party[key].global_position), FIRE_DONUT_INNER, FIRE_DONUT_OUTTER,
				FIRE_DONUT_LIFETIME, FIRE_DONUT_COLOR,[0, 2, "Fire Crystal", [party[party_boa["long_dps"]], party[party_boa["long_sup"]]]])
			fire_donut.collisions_checked.connect(on_kb_aoe_hit)
	# Water Crystal
	else:
		var players_hit := get_nearest_player_bodies(v2(water_circle.global_position), 2)
		for key in players_hit:
			var water_aoe = gac.spawn_circle(v2(party[key].global_position), WATER_AOE_RADIUS,
				WATER_AOE_LIFETIME, WATER_AOE_COLOR,[1, 3, "Water Crystal", [party[party_boa["long_dps"]], party[party_boa["long_sup"]]]])
			water_aoe.collisions_checked.connect(on_kb_aoe_hit)
			water_aoe_blacklist[water_aoe] = party[key]


# Handle knockbacks for fire/water crystal AoE's
func on_kb_aoe_hit(bodies: Array, marker: Node3D):
	var pos = marker.global_position
	for pc: PlayableCharacter in bodies:
		# Exclude water target from getting knocked back.
		if water_aoe_blacklist.has(marker):
			if water_aoe_blacklist[marker] == pc:
				continue
		if pc.is_player() and !Global.spectate_mode:
			knockback_player(pc, pos)
		# Always small kb for bots.
		else:
			var kb_vector: Vector2 = (v2(pc.global_position) - v2(pos)).normalized()
			pc.slide(kb_vector * SMALL_KB_DIST, SLIDE_TIME)
		pc.remove_debuff("tailwind")
		pc.remove_debuff("headwind")


func knockback_player(player: PlayableCharacter, from: Vector3):
	var kb_vector: Vector2 = (v2(player.global_position) - v2(from)).normalized()
	if !player.has_debuff("tailwind") and !player.has_debuff("headwind"):
		player.kb_slide(kb_vector * MED_KB_DIST, SLIDE_TIME)
		return
	var facing_target := false
	var player_rotation := fposmod((rad_to_deg(player.get_model_rotation().y) + 180), 360.0)
	var angle_to_gaze_target = fposmod(rad_to_deg(v2(player.global_position).angle_to_point(v2(from))) * -1 + 90, 360.0)
	if angle_to_gaze_target < KB_MIN_ANGLE:
		if player_rotation < angle_to_gaze_target + KB_MIN_ANGLE or player_rotation > KB_MAX_ANGLE + angle_to_gaze_target:
			facing_target = true
			print("facing aoe")
	elif angle_to_gaze_target > KB_MAX_ANGLE:
		if player_rotation > angle_to_gaze_target - KB_MIN_ANGLE or player_rotation < angle_to_gaze_target - KB_MAX_ANGLE:
			facing_target = true
			print("facing aoe")
	elif player_rotation > angle_to_gaze_target - KB_MIN_ANGLE and player_rotation < angle_to_gaze_target + KB_MIN_ANGLE:
		facing_target = true
		print("facing aoe")
	# Big Knockback
	if player_tailwind != facing_target:
		player.kb_slide(kb_vector * LARGE_KB_DIST, SLIDE_TIME)
	# Small Knockback
	else:
		player.kb_slide(kb_vector * SMALL_KB_DIST, SLIDE_TIME)

## Move to wind pos

# Handle wind crystal. This will hit 2 nearest first time.
func wind_hit():
	var players_hit := get_nearest_player_bodies(v2(wind_diamond.global_position), 2)
	for key in players_hit:
		gac.spawn_circle(v2(party[key].global_position), WIND_AOE_RADIUS, WIND_AOE_LIFETIME,
			WIND_AOE_COLOR, [2, 2, "Cyclone (Wind Crystal)", [party[key]]])


# Tank bait thunder
func move_tank_thunder_kb_1():
	# TODO: Handle no invuln strat. Have T1 take first hit
	exdeath_tank.move_to(v2(exdeath.global_position))


## Move to post wind spots
# Cast Thunder III (TB)
func cast_thunder_tb():
	cast("Thunder III", 4.7, exdeath)

# Thunder Hit 1 then 2, move tank in between
func thunder_kb_hit():
	var nearest = get_nearest_player_bodies(v2(exdeath.global_position), 1)
	gac.spawn_circle(v2(party[nearest.back()].global_position), THUNDER_TB_RADIUS,
		THUNDER_TB_LIFETIME, THUNDER_TB_COLOR, [1, 1, "Thunder III (Tank Buster)", [party[nearest.back()]]])

## Move tanks
# Swap tanks if we're not invulning.
# Chaos tank will move Chaos to middle.
func move_tank_thunder_kb_2():
	# Distance "through" middle we want to move Chaos.
	var target_pos: Vector2 = v2(chaos.global_position).normalized() * -10.0
	chaos_tank.move_to(target_pos)
# Thunder 2 hit

# Point Chaos true north for latlong
func move_tank_pre_latlong():
	chaos_tank.move_to(Vector2(0, -10))


# Set Exdeath follow
func set_exdeath_follow():
	exdeath.follow_target(exdeath_tank)


# Cast longitudinal/latitude Implosion + Anim. Kefka casts Trance
## Move to latlong safe spot]
func lat_long_cast():
	chaos.plant()
	chaos.get_model().start_lat_long()
	if lat_long:
		cast("Latitudinal Implosion", 5.4, chaos)
	else:
		cast("Longitudinal Implosion", 5.4, chaos)
	enemy_cast_bar.cast("Trance", 3.4)


func move_pre_latlong():
	var fire_water_rotation = arena_rotation_deg
	var wind_rotation = arena_rotation_deg
	if fire_left != fire_short:
		fire_water_rotation += 180.0
	
	# If arena is offset by 90 deg, switch to other spot.
	if !lat_long != (int(arena_rotation_deg) % 180 == 0):
		wind_rotation -= LATLONG_POSITION_ROTATION_DEG
		fire_water_rotation += LATLONG_POSITION_ROTATION_DEG
	else:
		wind_rotation += LATLONG_POSITION_ROTATION_DEG
		fire_water_rotation -= LATLONG_POSITION_ROTATION_DEG
	move_strat_party_and_rotate(BoAPos.LATLONG_NE_POS_SG, party_boa, wind_rotation)
	move_strat_party_and_rotate(BoAPos.LATLONG_SE_POS_SG, party_boa, fire_water_rotation)


# Prefire latlong anim
func lat_long_finish_anim():
	if lat_long:
		chaos.get_model().finish_lat_long()
	else:
		chaos.get_model().finish_long_lat()


# Latlong hits
func lat_long_hit_1():
	var facing_vector = chaos.get_global_transform().basis
	# Longitudinal Implosion (sides first)
	if lat_long:
		#var left_vector = facing_vector.x
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH,
			v2(facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])
	# Latitudinal Implosion (front/back first)
	else:
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(facing_vector.z + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.z + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])


func move_latlong_2():
	var fire_water_rotation = arena_rotation_deg
	var wind_rotation = arena_rotation_deg
	if fire_left != fire_short:
		fire_water_rotation += 180.0
	if !lat_long != (int(arena_rotation_deg) % 180 == 0):
		wind_rotation += LATLONG_POSITION_ROTATION_DEG
		fire_water_rotation -= LATLONG_POSITION_ROTATION_DEG
	else:
		wind_rotation -= LATLONG_POSITION_ROTATION_DEG
		fire_water_rotation += LATLONG_POSITION_ROTATION_DEG
	move_strat_party_and_rotate(BoAPos.LATLONG_NE_POS_SG, party_boa, wind_rotation)
	move_strat_party_and_rotate(BoAPos.LATLONG_SE_POS_SG, party_boa, fire_water_rotation)


func lat_long_hit_2():
	var facing_vector = chaos.get_global_transform().basis
	# Latitudinal Implosion (front/back first)
	if !lat_long:
		#var left_vector = facing_vector.x
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH,
			v2(facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.x + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Longitudinal Implosion"])
	# Longitudinal Implosion (sides first)
	else:
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(facing_vector.z + chaos.global_position ), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])
		gac.spawn_cone(v2(chaos.global_position), LATLONG_CONE_ANGLE, LATLONG_CONE_LENGTH, 
			v2(-facing_vector.z + chaos.global_position), LATLONG_CONE_LIFETIME, LATLONG_CONE_COLOR, [0, 0, "Latitudinal Implosion"])

## Move to second debuff spots
# If Longlat is set up correctly, we should already be close to these spots.
func move_long_debuff_pos():
	if fire_short:
		if fire_left:
			move_strat_party_rtd(BoAPos.LONG_WATER_POS_SG, party_boa)
		else:
			move_strat_party_rtd_mirrored(BoAPos.LONG_WATER_POS_SG, party_boa)
	else:
		if fire_left:
			move_strat_party_rtd(BoAPos.LONG_FIRE_POS_SG, party_boa)
		else:
			move_strat_party_rtd_mirrored(BoAPos.LONG_FIRE_POS_SG, party_boa)


# Trigger second set of debuffs
func long_debuff_hit():
	# Long debuffs hit
	# Entropy Hit
	if !fire_short:
		gac.spawn_circle(v2(party[party_boa["long_dps"]].global_position),
			ENTROPY_RADIUS, ENTROPY_LIFETIME, ENTROPY_COLOR, [1, 1, "Entropy Spread", [party[party_boa["long_dps"]]]])
		gac.spawn_circle(v2(party[party_boa["long_sup"]].global_position),
			ENTROPY_RADIUS, ENTROPY_LIFETIME, ENTROPY_COLOR, [1, 1, "Entropy Spread", [party[party_boa["long_sup"]]]])
	# Fluid Hit
	else:
		gac.spawn_donut(v2(party[party_boa["long_dps"]].global_position),
			DYNAMIC_INNER, DYNAMIC_OUTTER, DYNAMIC_LIFETIME, DYNAMIC_COLOR, [0, 0, "Dynamic Fluid Spread", [party[party_boa["long_dps"]]]])
		gac.spawn_donut(v2(party[party_boa["long_sup"]].global_position),
			DYNAMIC_INNER, DYNAMIC_OUTTER, DYNAMIC_LIFETIME, DYNAMIC_COLOR, [0, 0, "Dynamic Fluid Spread", [party[party_boa["long_sup"]]]])


# Trigger shapes
func second_shapes_hit():
	# Handle shapes trigger. We assume that the correct number of debuffs went off.
	# Fire Crystal
	if !fire_short:
		var players_hit := get_nearest_player_bodies(v2(fire_triangle.global_position), 2)
		for key in players_hit:
			var fire_donut = gac.spawn_donut(v2(party[key].global_position), FIRE_DONUT_INNER, FIRE_DONUT_OUTTER,
				FIRE_DONUT_LIFETIME, FIRE_DONUT_COLOR,[0, 2, "Fire Crystal", [party[party_boa["short_dps"]], party[party_boa["short_sup"]]]])
			fire_donut.collisions_checked.connect(on_kb_aoe_hit)
	# Water Crystal
	else:
		var players_hit := get_nearest_player_bodies(v2(water_circle.global_position), 2)
		for key in players_hit:
			var water_aoe = gac.spawn_circle(v2(party[key].global_position), WATER_AOE_RADIUS,
				WATER_AOE_LIFETIME, WATER_AOE_COLOR,[0, 3, "Water Crystal", [party[party_boa["short_dps"]], party[party_boa["short_sup"]]]])
			water_aoe.collisions_checked.connect(on_kb_aoe_hit)

# Set chaos follow
#func set_chaos_follow():
## Post debuff movement
# Trigger wind hit
#func wind_hit():
	
## Move post wind.
func move_jump_bait_pos():
	move_party_rtd(BoAPos.UMBRA_BAIT_POS_SG)


# Cast Chaos Umbra Smash, Exdeath cast Vaccum Wave
func cast_umbra_vaccum():
	chaos.plant()
	exdeath.plant()
	cast("Umbra Smash", 4.7, chaos)
	cast("Vaccum Wave", 7.4, exdeath)
	var umbra_target = get_nearest_player_bodies(v2(chaos.global_position), 8).back()
	umbra_target_pos = party[umbra_target].global_position
	chaos.look_at_direction(umbra_target_pos)

## Move ranged baiter to group.
func move_pre_vaccum_pos():
	move_party_rtd(BoAPos.UMBRA_CAST_POS_SG)


# Kefka starts charges
# Call for first LC charge only
func lc_charge_start():
	kefka.play_fade_out()
	current_lc_pos = LC_LINE_START_POS
	current_lc_pos = current_lc_pos.rotated(deg_to_rad(lc_rotation_deg * lc_direction_factor))
	# Store reverse starting positions for LC charges
	var reverse_pos = current_lc_pos
	for i in 8:
		lc_starting_positions.append(reverse_pos)
		reverse_pos = reverse_pos.rotated(deg_to_rad(45.0 * -lc_direction_factor))
	lc_charge()

# Call LC's 2-8.
func lc_charge():
	gac.spawn_line(current_lc_pos, LC_LINE_WIDTH - 10.0, LC_LINE_LENGTH,
		LC_LINE_TARGET, LC_LINE_LIFETIME, LC_LINE_COLOR)
	# Move Kefka
	kefka.global_position = v3(current_lc_pos)
	kefka.look_at(Vector3.UP, Vector3.UP, true)
	kefka.play_lc_dash()
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(kefka, "global_position", 
		Vector3.ZERO, 1.6)\
		.set_trans(Tween.TRANS_LINEAR)
	current_lc_pos = current_lc_pos.rotated(deg_to_rad(45.0 * lc_direction_factor))
	
	#tween.tween_property(kefka, "global_position", 
		#kefka.global_position.normalized().rotated(Vector3.UP, deg_to_rad(180.0)) * 20.0, 1.6)\
		#.set_trans(Tween.TRANS_LINEAR)


# Chaos jump anim prefire (call 0.75s before jump movement)
func umbra_jump_anim():
	if starting_point == StartPoint.LC:
		return
	chaos.get_model().cast_jump()

# Chaos start jump movement
func umbra_jump_movement():
	if starting_point == StartPoint.LC:
		return
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(chaos, "global_position", umbra_target_pos, 0.6)\
		.set_trans(Tween.TRANS_LINEAR)

# Call 0.6s after jump movement.
func unbra_jump_land():
	if starting_point == StartPoint.LC:
		return
	gac.spawn_circle(v2(umbra_target_pos), UMBRA_RADIUS, UMBRA_LIFETIME, UMBRA_COLOR, [0, 0, "Umbra Smash (Proximity AoE)"])

func vaccum_wave_anim():
	if starting_point == StartPoint.LC:
		return
	exdeath.get_model().cast_slash()

# Vaccum Wave hits
func vaccum_wave_hit():
	if starting_point == StartPoint.LC:
		return
	# Just used for animation.
	gac.spawn_circle(v2(exdeath.global_position), VACCUM_RADIUS, VACCUM_LIFETIME, VACCUM_COLOR)
	# Knockback party. Skip fire/water debuff bots (assume they pressed arm's length)
	for key: String in party_boa:
		#if (key.contains("short") or key.contains("long")) and party[key].is_player():
			#continue
		# Everyone else will get knocked back.
		var pc: PlayableCharacter = party[party_boa[key]]
		if pc.is_player() and !Global.spectate_mode:
			knockback_player(pc, exdeath.global_position)
		else:
			var kb_vector: Vector2 = (v2(pc.global_position) - v2(exdeath.global_position)).normalized()
			pc.slide(kb_vector * MED_KB_DIST, SLIDE_TIME)
		
			
 #cast_slash()


# Move to Wind 3 Pos
func move_winds_3_pos():
	if starting_point == StartPoint.LC:
		return
	move_party_rtd(BoAPos.WINDS_3_BAIT_POS)


# Limit cut goes out
func show_lc_icons():
	for i in party_keys_lc.size():
		lockon_controller.add_marker(LC_ID_KEYS[i], party[party_keys_lc[i]])

func wind_3_hit():
	if starting_point == StartPoint.LC:
		return
	var players_hit := get_nearest_player_bodies(v2(wind_diamond.global_position), 4)
	for key in players_hit:
		gac.spawn_circle(v2(party[key].global_position), WIND_AOE_RADIUS, WIND_AOE_LIFETIME,
			WIND_AOE_COLOR, [2, 2, "Cyclone (Wind Crystal)", [party[key]]])


## Move to limit cut pos

# After 8s, hide LC Icons
func hide_lc_icons():
	for i in party_keys_lc.size():
		lockon_controller.remove_marker(LC_ID_KEYS[i], party[party_keys_lc[i]])


func move_lc_pos():
	# Starting position. First dash is relative N to S, so we'll start CW or CCW of S.
	var pos = Vector2(0.0, 45.0).rotated(deg_to_rad(lc_rotation_deg * lc_direction_factor))
	pos = pos.rotated(deg_to_rad(22.5 * -lc_direction_factor))
	for i in party.size():
		party[party_keys_lc[i]].move_to(pos)
		pos = pos.rotated(deg_to_rad(45.0 * -lc_direction_factor))



# There is a very small (~0.1s) delay between each hit.
# Starts at same pos as initial dash, but rotates opposite direction (0 > 7 > 6 > 5...)
# They presumably have proximity damage, which we'll also ignore for now.
func limit_cut_hit(lc_number: int):
	#var pos_index = 8 - lc_number
	## First hit is from the same position.
	#if pos_index == 8:
		#pos_index = 0
	
	gac.spawn_line(lc_starting_positions[lc_number], LC_LINE_WIDTH, LC_LINE_LENGTH,
		v2(party[party_keys_lc[lc_number]].global_position), LC_LINE_LIFETIME, 
		LC_LINE_COLOR, [1, 1, "Ultima Blaster (Limit Cut)", [party[party_keys_lc[lc_number]]]])
	

## END OF TIMELINE


# Make sure the keys in both Dictionaries match.
func move_strat_party_rtd(position_dict: Dictionary, role_keys_dict: Dictionary):
	for key in position_dict:
		if !role_keys_dict.has(key) or role_keys_dict[key] == null:
			continue
		party[role_keys_dict[key]].move_to(position_dict[key].rotated(deg_to_rad(arena_rotation_deg)))


func move_strat_party_and_rotate(position_dict: Dictionary, role_keys_dict: Dictionary, rotation: float):
	for key in position_dict:
		if !role_keys_dict.has(key) or role_keys_dict[key] == null:
			continue
		party[role_keys_dict[key]].move_to(position_dict[key].rotated(deg_to_rad(rotation)))


# Will also mirror the coordinates along the Wind Crystal Axis
func move_strat_party_rtd_mirrored(position_dict: Dictionary, role_keys_dict: Dictionary):
	for key in position_dict:
		if !role_keys_dict.has(key) or role_keys_dict[key] == null:
			continue
		party[role_keys_dict[key]].move_to(flip_neg_xy(position_dict[key]).rotated(deg_to_rad(arena_rotation_deg)))


# Will also mirror the coordinates along the Wind Crystal Axis
func move_party_rtd_mirrored(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			var flipped = flip_neg_xy(position_dict[key])
			var rotated = flipped.rotated(deg_to_rad(arena_rotation_deg))
			party[key].move_to(rotated)
			#party[key].move_to(flip_neg_xy(position_dict[key]).rotated(deg_to_rad(arena_rotation_deg)))


func move_party_rtd(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key].rotated(deg_to_rad(arena_rotation_deg)))


func move_party(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key])


func move_party_and_rotate(position_dict: Dictionary, rotation_deg: float):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key]).rotated(deg_to_rad(rotation_deg))


func cast(spell_name: String, cast_time: float, caster: Node3D):
	target_cast_bar.cast(spell_name, cast_time, caster)
	enemy_cast_bar.cast(spell_name, cast_time)


## HELPER FUNCTIONS

# Used for mirror along Wind crystal axis
func flip_neg_xy(pos: Vector2) -> Vector2:
	return Vector2(-pos.y, -pos.x)


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
