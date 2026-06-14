# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# TODO: pause on fail.

extends Node

class_name P2ForsSequence

enum Strat {RIN, SOUTH, EU, ABBA}   
enum SoakOrder {AAAB, ABBA}
enum AdjustPrio {RMMR, FLEX, SOUTH}
enum OddTowerPos {RIN, EU, BOSS, NS}   
enum EvenTowerPos {RIN, EU, OUTTER, BOSS}     # BOSS = old rin boss align 90 deg
enum Lockon {CONE, SPREAD, STACK}

## Strat Specs
const STRAT_PRESET := {
	Strat.RIN: {
		"soak_order": SoakOrder.AAAB,
		"adjust_prio": AdjustPrio.RMMR,
		"odd_position": OddTowerPos.RIN,
		"even_position" : EvenTowerPos.RIN,
		"special_rule": false,
	},
	Strat.SOUTH: {
		"soak_order": SoakOrder.AAAB,
		"adjust_prio": AdjustPrio.SOUTH,
		"odd_position": OddTowerPos.BOSS,
		"even_position" : EvenTowerPos.RIN,
		"special_rule": false,
	},
	Strat.EU: {
		"soak_order": SoakOrder.AAAB,
		"adjust_prio": AdjustPrio.RMMR,
		"odd_position": OddTowerPos.EU,
		"even_position" : EvenTowerPos.EU,
		"special_rule": true,
	},
	Strat.ABBA: {
		"soak_order": SoakOrder.ABBA,
		"adjust_prio": AdjustPrio.RMMR,
		"odd_position": OddTowerPos.RIN,
		"even_position" : EvenTowerPos.RIN,
		"special_rule": false,
	},
}


const A_TOWER_SOAKS := {
	SoakOrder.AAAB: [1, 2, 3, 8],
	SoakOrder.ABBA: [1, 4, 5, 8]
}

const POSITION_DICT := {
	"lineup": {
		OddTowerPos.RIN: ForsPositions.LINEUP_POS_RIN,
		OddTowerPos.BOSS: ForsPositions.LINEUP_POS_RIN,
		OddTowerPos.EU: ForsPositions.LINEUP_POS_EU,
	},
	"odd_tower_in": {
		OddTowerPos.RIN: ForsPositions.V1_IN_POS_RIN,
		OddTowerPos.BOSS: ForsPositions.V1_IN_POS_BOSS_ALIGN,
		OddTowerPos.EU: ForsPositions.V1_IN_POS_EU,
		OddTowerPos.NS: ForsPositions.V1_IN_POS_ABBA
	},
	"odd_tower_soak": {
		OddTowerPos.RIN: ForsPositions.V1_STACK_POS_RIN,
		OddTowerPos.BOSS: ForsPositions.V1_STACK_POS_BOSS_ALIGN,
		OddTowerPos.EU: ForsPositions.V1_STACK_POS_EU,
		OddTowerPos.NS: ForsPositions.V1_STACK_POS_ABBA
	},
	"even_tower_in": {
		EvenTowerPos.RIN: ForsPositions.V2_IN_POS_RIN,
		EvenTowerPos.OUTTER: ForsPositions.V2_IN_POS_OUTTER,
		EvenTowerPos.EU: ForsPositions.V2_IN_POS_EU,
		EvenTowerPos.BOSS: ForsPositions.V2_IN_POS_BOSS,
	},
	"even_tower_soak": {
		EvenTowerPos.RIN: ForsPositions.V2_BAIT_POS_RIN,
		EvenTowerPos.OUTTER: ForsPositions.V2_BAIT_POS_OUTTER,
		EvenTowerPos.EU: ForsPositions.V2_BAIT_POS_EU,
		EvenTowerPos.BOSS: ForsPositions.V2_BAIT_POS_BOSS,
	},
}

## Resource Preload
const GOD_KEFKA_UID = "uid://c8p51pmt3xvde"

## Debuff Icon Scenes
const TROUBLE_ICON = preload("uid://r88tce2vd75y")
const TROUBLE_DEBUFF = "trouble"

## AoE Dimensions
# Lockon Cone shot by player
const CONE_ANGLE_DEG := 123.0
const CONE_LENGTH := 50.0
const CONE_LIFETIME := 0.5
const CONE_COLOR := Color.ORANGE
# Lockon Spread around player
const SPREAD_RADIUS := 11.2
const SPREAD_LIFETIME := 0.5
const SPREAD_COLOR := Color.ORANGE_RED
# Lockon Stack around player
const STACK_RADIUS := 13.0
const STACK_LIFETIME := 0.5
const STACK_COLOR := Color.GOLD
# Clone jump/AoE at the end of Furture/Past cast
const CLONE_JUMP_AOE_RADIUS := 11.2
const CLONE_JUMP_AOE_LIFETIME := 0.5
const CLONE_JUMP_AOE_COLOR := Color.RED
const CLONE_JUMP_BUFFER := 15.0   # Min distance at which clone will not jump
const CLONE_JUMP_DURATION := 0.5
const CLONE_TURN_SPEED := 0.7
# Baited All Things Ending cone, shot by clones and boss
const CLONE_CONE_ANGLE := 179.0
const CLONE_CONE_LENGTH := 50.0
const CLONE_CONE_LIFETIME := 0.5
const CLONE_CONE_COLOR := Color.RED
# Other
const TOWER_DURATION := 10.65   # This doesn't do anything atm. Duration is setup in fr_tower animation.


## Lineup Prio
const DPS_KEYS := ["m1", "m2", "r1", "r2"]
const SUP_KEYS := ["h2", "h1", "t2", "t1"]
const LOCKON_IDS := [16, 18, 17]  # Cone, Spread, Stack

## NPC Positions
const TOWER_POS := {
	"north": Vector2(0, -18.25),
	"east": Vector2(18.25, 0)
}
const CLONE_POS := [Vector3.ZERO, Vector3(0, 0, -1.0), Vector3(1.0, 0, 0), Vector3(0, 0, 1.0)]

@onready var enemies: Node3D = get_tree().get_first_node_in_group("enemies_layer")
@onready var fail_list: FailList = %FailList
@onready var p2_fors_anim: AnimationPlayer = %P2ForsAnim
@onready var cast_bar: CastBar = %CastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
@onready var kefka: Node3D = %GodKefka
@onready var boss: Node3D = %Boss   # Use this for moving/rotating boss

## Old Kefkabin - Used for tower soaking positions
const KB_LR_PRIO := ["h1", "h2", "t1", "t2", "r1", "r2", "m1", "m2"]
const KB_BAIT_SETUP := ["h1", "t1", "h2", "t2", "r1", "m1", "r2", "m2"]

var party_a: Dictionary
var party_b: Dictionary
	#"stack_left": null, "stack_right": null,
	#"cone_left": null, "cone_right": null,
	#"spread_left": null, "spread_right": null
# Used for Past/Future baits in center
var party_baits: Dictionary
	#"a_g1_dps": null, "a_g1_sup": null,
	#"a_g2_dps": null, "a_g2_sup": null,
	#"b_g1_dps": null, "b_g1_sup": null,
	#"b_g2_dps": null, "b_g2_sup": null,

## RMMR (new kefkabin)
const RMMR_PRIO := ["h1", "h2", "t1", "t2", "m1", "m2", "r1", "r2"]
# A/B partners are LP buddy (e.g T1+H1)
# Used for Tower 2 baiters. Keys = "h","t","m","r"
var party_baits_a : Dictionary
var party_baits_b : Dictionary

var party: Dictionary
var strat: Strat
var soak_order: SoakOrder
var adjust_prio: AdjustPrio
var odd_tower_pos: OddTowerPos
var even_tower_pos: EvenTowerPos
var eu_setup: bool
var lockon_keys: Dictionary[String, Lockon]
var dps_cones: bool
var arena_rotation_deg: float
var rotation_direction: float
var fr_towers := []   # [right, left] relative south towers
var odd_tower_lockons := [Lockon.CONE, Lockon.CONE, Lockon.SPREAD, Lockon.SPREAD]
var even_tower_lockons := [Lockon.CONE, Lockon.SPREAD, Lockon.STACK, Lockon.STACK]
var clone_scene: PackedScene
var clones: Array[Node3D]
var clone_snapshot_pos: Array
var is_future: bool
var group_a_keys : Array
var group_b_keys : Array
var player_bait: bool
var player_key: String


func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	ground_aoe_controller.preload_aoe(["cone", "circle", "fr_tower"])
	lockon_controller.pre_load([LockonController.CONE, LockonController.STACK, LockonController.TARGET])
	ResourceLoader.load_threaded_request(GOD_KEFKA_UID)
	clones.append(boss)
	
	## Get Strat and variables.
	#strat = DmuSavedVariables.save_data["settings"]["p2_fors_strat"]
	
	soak_order = DmuSavedVariables.get_data_and_check_int("settings", "p2_fors_soak_order", 0, SoakOrder.size()) as SoakOrder
	adjust_prio = DmuSavedVariables.get_data_and_check_int("settings", "p2_fors_adjust_prio", 0, AdjustPrio.size()) as AdjustPrio
	odd_tower_pos = DmuSavedVariables.get_data_and_check_int("settings", "p2_fors_odd_tower_pos", 0, OddTowerPos.size()) as OddTowerPos
	even_tower_pos = DmuSavedVariables.get_data_and_check_int("settings", "p2_fors_even_tower_pos", 0, EvenTowerPos.size()) as EvenTowerPos
	eu_setup = DmuSavedVariables.get_data_and_check_bool("settings", "p2_fors_special_rule")
	player_bait = DmuSavedVariables.get_data_and_check_bool("settings", "p2_fors_bait")
	player_key = Global.player_role_key
	
	instantiate_party(new_party)
	## Start animation sequence
	p2_fors_anim.play("p2_fors")
	#spawn_test_towers()


func instantiate_party(new_party: Dictionary):
	party = new_party
	# RNG for arena and party setup
	arena_rotation_deg = randi_range(0, 7) * 45.0
	rotation_direction = 1.0 if randi() % 2 == 0 else -1.0
	dps_cones = randi() % 2 == 0
	var dps_stack_index = randi_range(0, 3)
	var sup_stack_index = randi_range(0, 3)
	# Add DPS to lockon_keys dictionary with starting lockons.
	for i in DPS_KEYS.size():
		if i == dps_stack_index:
			lockon_keys[DPS_KEYS[i]] = Lockon.STACK
		elif dps_cones:
			lockon_keys[DPS_KEYS[i]] = Lockon.CONE
		else:
			lockon_keys[DPS_KEYS[i]] = Lockon.SPREAD
	# Same for supports.
	for i in SUP_KEYS.size():
		if i == sup_stack_index:
			lockon_keys[SUP_KEYS[i]] = Lockon.STACK
		elif dps_cones:
			lockon_keys[SUP_KEYS[i]] = Lockon.SPREAD
		else:
			lockon_keys[SUP_KEYS[i]] = Lockon.CONE
	
	# KB group setup (deprecated)
	#if strat == Strat.KB:
		#var sup_stack_key = SUP_KEYS[sup_stack_index]
		#var dps_stack_key = DPS_KEYS[dps_stack_index]
		#group_a_keys = [sup_stack_key, get_role_partner_key(sup_stack_key), dps_stack_key,  get_role_partner_key(dps_stack_key)]
		#group_b_keys = KB_LR_PRIO.duplicate().filter(func(key): return !group_a_keys.has(key))
		## Sorts group key arrays sup1>sup2>dps1>dps2 for bait prio
		#order_lr_prio(KB_BAIT_SETUP, group_a_keys)
		#order_lr_prio(KB_BAIT_SETUP, group_b_keys)
		#party_baits = {
			#"a_g1_sup": group_a_keys[0], "a_g2_sup": group_a_keys[1],
			#"a_g1_dps": group_a_keys[2], "a_g2_dps": group_a_keys[3],
			#"b_g1_sup": group_b_keys[0], "b_g2_sup": group_b_keys[1],
			#"b_g1_dps": group_b_keys[2], "b_g2_dps": group_b_keys[3]
		#}
		#repopulate_groups_rmmr(party_a, group_a_keys, KB_LR_PRIO)
		#repopulate_groups_rmmr(party_b, group_b_keys, KB_LR_PRIO)
	
	# RMMR / South / EU adjust initial group setup.
	var sup_stack_key = SUP_KEYS[sup_stack_index]
	var dps_stack_key = DPS_KEYS[dps_stack_index]
	# Stacks + light party partner in group A
	group_a_keys = [sup_stack_key, get_lp_partner_key(sup_stack_key), dps_stack_key,  get_lp_partner_key(dps_stack_key)]
	# Everyone else in group B
	group_b_keys = RMMR_PRIO.duplicate().filter(func(key): return !group_a_keys.has(key))
	# Sorts group key arrays H>T>M>R for bait prio
	order_lr_prio(RMMR_PRIO, group_a_keys)
	order_lr_prio(RMMR_PRIO, group_b_keys)    # Should already be sorted
	party_baits_a = {
		"h":  group_a_keys[0], "t":  group_a_keys[1],
		"m":  group_a_keys[2], "r":  group_a_keys[3]
	}
	party_baits_b = {
		"h": group_b_keys[0], "t": group_b_keys[1],
		"m": group_b_keys[2], "r": group_b_keys[3]
	}
	repopulate_groups(party_b, group_b_keys)
	# Exception for EU initial setup, group A follows buddy, group B uses RMMR
	if eu_setup:
		eu_group_setup(party_a, group_a_keys)
	else:
		repopulate_groups(party_a, group_a_keys)


# Uses RMMR prio with option for flex adjustments. Can be used for initial setup.
# Note this doesn't handle unexpected marker distribution, i.e when someone takes a wrong tower.
func repopulate_groups(group_dict: Dictionary, group_keys: Array):
	var stack_keys: Array
	var spread_keys: Array
	var cone_keys: Array
	var old_left_keys : Array
	var old_right_keys : Array
	
	for key in group_keys:
		var lockon_key = lockon_keys[key]
		match lockon_key:
			Lockon.CONE:
				cone_keys.append(key)
			Lockon.SPREAD:
				spread_keys.append(key)
			Lockon.STACK:
				stack_keys.append(key)
	
	# Flex RMMR Prio: save right 2 soakers from last tower.
	# If we're getting stacks on this round, last round was T2 (2 cone, 2 spread)
	if adjust_prio == AdjustPrio.FLEX and !group_dict.is_empty():
		# Odd Tower (2x Stacks / 1x Cone / 1x Spread)
		if stack_keys.size() == 2:
			old_left_keys = [group_dict.get("cone_left"), group_dict.get("spread_left")]
			order_lr_prio(RMMR_PRIO, stack_keys)
			# Right stack key on left side. Swap keys.
			if old_left_keys.has(stack_keys[1]) and !old_left_keys.has(stack_keys[0]):
				stack_keys.append(stack_keys.pop_front())
			# Populate Dictionary
			group_dict.clear()
			group_dict.merge({"stack_left": stack_keys[0], "stack_right": stack_keys[1],
				"spread_left": spread_keys.front(), "cone_left": cone_keys.front()})
			return
		# Even Tower (2x Cone / 2x Spread)
		elif spread_keys.size() == 2 and cone_keys.size() == 2:
			# Ordered left to right adjust prio for next tower.
			order_lr_prio(RMMR_PRIO, spread_keys)
			order_lr_prio(RMMR_PRIO, cone_keys)
			old_left_keys = [group_dict.get("stack_left"), group_dict.get("cone_left")]
			#old_right_keys = [group_dict.get("spread_left"), group_dict.get("stack_right")]
			# Right cone on left side or Left cone on right side.
			if old_left_keys.has(cone_keys[1]) and !old_left_keys.has(cone_keys[0]):
				cone_keys.append(cone_keys.pop_front())
			# Right spread on left side.
			if old_left_keys.has(spread_keys[1]) and !old_left_keys.has(spread_keys[0]):
				spread_keys.append(spread_keys.pop_front())
			# Populate dictionary
			group_dict.clear()
			group_dict.merge({"spread_left": spread_keys[0], "spread_right": spread_keys[1],
				"cone_left": cone_keys[0], "cone_right": cone_keys[1]}) 
			return
	
	
	# South Adjust prio
	if adjust_prio == AdjustPrio.SOUTH and !group_dict.is_empty():
		# Odd Tower (2x Stacks / 1x Cone / 1x Spread)
		if stack_keys.size() == 2:
			# Ordered such that higher index is south for adjust prio.
			old_left_keys = [group_dict.get("cone_left"), group_dict.get("spread_left")]
			if stack_keys.has(old_left_keys[0]) and stack_keys.has(old_left_keys[1]):
				# Both stacks left. Spread left will adjust.
				stack_keys = old_left_keys
			elif !stack_keys.has(old_left_keys[0]) and !stack_keys.has(old_left_keys[1]):
				# Both stacks right. Spred right will adjust.
				stack_keys = [group_dict.get("spread_right"), group_dict.get("cone_right")]
			else:
				# 1 on each side. Just need to determine which stack is on which side.
				if old_left_keys.has(stack_keys[1]):
					stack_keys.append(stack_keys.pop_front())
					assert(old_left_keys.has(stack_keys[0]))
			# Populate dictionary
			group_dict.clear()
			group_dict.merge({"stack_left": stack_keys[0], "stack_right": stack_keys[1],
				"spread_left": spread_keys.front(), "cone_left": cone_keys.front()
			})
			return
		# Even Tower (2x Cone / 2x Spread)
		elif spread_keys.size() == 2 and cone_keys.size() == 2:
			# Ordered left to right adjust prio for next tower.
			old_left_keys = [group_dict.get("stack_left"), group_dict.get("cone_left")]
			if odd_tower_pos == OddTowerPos.EU:
				# p3Z positions put the stack right player south and spread north so we need to swap the prio in this case
				old_right_keys = [group_dict.get("stack_right"), group_dict.get("spread_left")]
			else:
				old_right_keys = [group_dict.get("spread_left"), group_dict.get("stack_right")]
			if cone_keys.has(old_left_keys[0]) and cone_keys.has(old_left_keys[1]):
				# Both Cones left. Keys are already ordered L>R for double swap.
				cone_keys = old_left_keys
				spread_keys = old_right_keys
			elif cone_keys.has(old_right_keys[0]) and cone_keys.has(old_right_keys[1]):
				# Both Cones right. Keys are already ordered L>R for double swap.
				cone_keys = old_right_keys
				spread_keys = old_left_keys
			else:
				# 1 on each side. Order arrays so left key is first.
				if old_left_keys.has(cone_keys[1]):
					cone_keys.append(cone_keys.pop_front())
				if old_left_keys.has(spread_keys[1]):
					spread_keys.append(spread_keys.pop_front())
			# Populate dictionary
			group_dict.clear()
			group_dict.merge({"spread_left": spread_keys[0], "spread_right": spread_keys[1],
				"cone_left": cone_keys[0], "cone_right": cone_keys[1]})
			return
	
	# Default RMMR prio
	# Odd Tower (2x Stacks / 1x Cone / 1x Spread)
	if stack_keys.size() == 2:
		order_lr_prio(RMMR_PRIO, stack_keys)
		# Populate dictionary
		group_dict.clear()
		group_dict.merge({"stack_left": stack_keys.get(0), "stack_right": stack_keys.get(1),
			"spread_left": spread_keys.front(), "cone_left": cone_keys.front()
		})
	
	# Even Tower (2x Cone / 2x Spread)
	elif spread_keys.size() == 2 and cone_keys.size() == 2:
		order_lr_prio(RMMR_PRIO, cone_keys)
		order_lr_prio(RMMR_PRIO, spread_keys)
		# Populate dictionary
		group_dict.clear()
		group_dict.merge({"spread_left": spread_keys[0], "spread_right": spread_keys[1],
			"cone_left": cone_keys[0], "cone_right": cone_keys[1]})


# South players adjust. Use RMMR for initial setup.
#func repopulate_groups_south(group_dict: Dictionary, group_keys: Array):
	#var stack_keys: Array
	#var spread_keys: Array
	#var cone_keys: Array
	#var old_left_keys : Array
	#var old_right_keys : Array
	#
	#for key in group_keys:
		#var lockon_key = lockon_keys[key]
		#match lockon_key:
			#Lockon.CONE:
				#cone_keys.append(key)
			#Lockon.SPREAD:
				#spread_keys.append(key)
			#Lockon.STACK:
				#stack_keys.append(key)
	#
	## Odd Tower (2x Stacks / 1x Cone / 1x Spread)
	#if stack_keys.size() == 2:
		## Ordered such that higher index is south for adjust prio.
		#old_left_keys = [group_dict.get("cone_left"), group_dict.get("spread_left")]
		#if stack_keys.has(old_left_keys[0]) and stack_keys.has(old_left_keys[1]):
			## Both stacks left. Spread left will adjust.
			#stack_keys = old_left_keys
		#elif !stack_keys.has(old_left_keys[0]) and !stack_keys.has(old_left_keys[1]):
			## Both stacks right. Spred right will adjust.
			#stack_keys = [group_dict.get("spread_right"), group_dict.get("cone_right")]
		#else:
			## 1 on each side. Just need to determine which stack is on which side.
			#if old_left_keys.has(stack_keys[1]):
				#stack_keys.append(stack_keys.pop_front())
				#assert(old_left_keys.has(stack_keys[0]))
		## Populate dictionary
		#group_dict.clear()
		#group_dict.merge({"stack_left": stack_keys[0], "stack_right": stack_keys[1],
			#"spread_left": spread_keys.front(), "cone_left": cone_keys.front()
		#})
	#
	## Even Tower (2x Cone / 2x Spread)
	#elif spread_keys.size() == 2 and cone_keys.size() == 2:
		## Ordered left to right adjust prio for next tower.
		#old_left_keys = [group_dict.get("stack_left"), group_dict.get("cone_left")]
		#old_right_keys = [group_dict.get("spread_left"), group_dict.get("stack_right")]
		#if cone_keys.has(old_left_keys[0]) and cone_keys.has(old_left_keys[1]):
			## Both Cones left. Keys are already ordered L>R for double swap.
			#cone_keys = old_left_keys
			#spread_keys = old_right_keys
		#elif cone_keys.has(old_right_keys[0]) and cone_keys.has(old_right_keys[1]):
			## Both Cones right. Keys are already ordered L>R for double swap.
			#cone_keys = old_right_keys
			#spread_keys = old_left_keys
		#else:
			## 1 on each side. Order arrays so left key is first.
			#if old_left_keys.has(cone_keys[1]):
				#cone_keys.append(cone_keys.pop_front())
			#if old_left_keys.has(spread_keys[1]):
				#spread_keys.append(spread_keys.pop_front())
		## Populate dictionary
		#group_dict.clear()
		#group_dict.merge({"spread_left": spread_keys[0], "spread_right": spread_keys[1],
			#"cone_left": cone_keys[0], "cone_right": cone_keys[1]})


# Used for initial setup of group A for EU, where spreads follow their partner.
func eu_group_setup(group_dict: Dictionary, group_keys: Array):
	var stack_keys: Array
	var spread_keys: Array
	var cone_keys: Array
	#var old_left_keys : Array
	#var old_right_keys : Array
	
	for key in group_keys:
		var lockon_key = lockon_keys[key]
		match lockon_key:
			Lockon.CONE:
				cone_keys.append(key)
			Lockon.SPREAD:
				spread_keys.append(key)
			Lockon.STACK:
				stack_keys.append(key)
	
	# Initial Group A setup. Stack follows their cone/spread partner.
	# stack_keys order [cone partner, spread partner]
	if group_dict.is_empty() and stack_keys.size() == 2:
		if spread_keys.has(get_lp_partner_key(stack_keys[0])):
			stack_keys.append(stack_keys.pop_front())
		
		group_dict.merge({"spread_left": spread_keys.front(), "cone_left": cone_keys.front(),
			"stack_left": stack_keys.front(), "stack_right": stack_keys.back()})
		return


### START OF TIMELINE ###

## 0.00

## Cast Forsaken + Anim
func cast_forsaken():
	cast_bar.cast("Forsaken", 3.0)
	kefka.cast_1_start()

# Move to Lineup positions. Not rotated.
func move_pre_pos():
	# Using odd tower selection to determine initial lineup, rather than making seperate option.
	if !POSITION_DICT["lineup"].has(odd_tower_pos):
		move_party(ForsPositions.LINEUP_POS_RIN)
		return
	move_party(POSITION_DICT["lineup"][odd_tower_pos])
	
	#match strat:
		##Strat.KB:
			##move_party(ForsPositions.LINEUP_POS_KB)
		#Strat.RIN, Strat.SOUTH:
			#move_party(ForsPositions.LINEUP_POS_UA)
		#Strat.EU:
			#move_party(ForsPositions.LINEUP_POS_EU)
		#Strat.ABBA:
			#move_party(ForsPositions.LINEUP_POS_ABBA)


## At cast finish (anim): First set of lockons (3 target, 3 cone, 2 stack) and debuffs. First 2 towers.
func forsaken_hit():
	kefka.cast_1_finish()
	# Give players first set of lockons. Add Spells Trouble debuff.
	for key in lockon_keys:
		lockon_controller.add_marker(LOCKON_IDS[lockon_keys[key]], party[key])
		party[key].add_debuff(TROUBLE_ICON, 0.0, true, TROUBLE_DEBUFF, 4)
	# Spawn towers
	fr_towers.append(ground_aoe_controller.spawn_fr_tower(TOWER_POS["north"].rotated(deg_to_rad(arena_rotation_deg)), TOWER_DURATION))
	fr_towers.append(ground_aoe_controller.spawn_fr_tower(TOWER_POS["east"].rotated(deg_to_rad(arena_rotation_deg)), TOWER_DURATION))


# 5s after forsaken hit, hide lockons.
# remove_lockons()

## Move to tower 1 pos.
func move_t1_pos():
	move_tower_pos(1)
	#
	#match strat:
		#Strat.KB:
			## V1 A=in B=stacks
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_KB, party_a)
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_KB, party_b)
		#Strat.ABBA:
			## V1 A=in B=stacks
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_ABBA, party_a)
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_ABBA, party_baits_b)
		#Strat.RIN, Strat.SOUTH:
			## V1 A=in B=stacks
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_UA, party_a)
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_UA, party_baits_b)
		#Strat.EU:
			## V1 A=in B=stacks
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_EU, party_a)
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_EU, party_baits_b)


# 11s after forsaken hit
## Tower 1 hit, despawn tower and do checks. Assign new lockons. Spawns towers 2
func tower_1_hit():
	check_towers(1)
	# Repopulate lockon dictionaries for group that got hit.
	repopulate_post_tower(1)
	spawn_towers_and_rotate()

## Cast Future/Past's End 1
func future_cast_1():
	future_cast()

# Move to tower 2 pos
func move_t2_pos():
	move_tower_pos(2)
	
	#match strat:
		#Strat.KB:
			## V2 A=bait B=in
			#move_strat_party_rtd(ForsPositions.V2_BAIT_A_POS_KB, party_baits)
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_KB, party_b)
		#Strat.RIN:
			## V2 A=in B=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_UA, party_a)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_UA, party_baits_b)
		#Strat.ABBA:
			## V2 A=bait B=in
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_ABBA, party_baits_a)
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_ABBA, party_b)
		#Strat.EU:
			## V2 A=in B=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_EU, party_a)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_EU, party_baits_b)
		#Strat.SOUTH:
			## V2 A=in B=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_OUTTER, party_a)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_OUTTER, party_baits_b)


# 5s after tower 1 hit, hide lockons

## Tower 2 hit with first clone spawn
func tower_2_hit():
	spawn_clones()
	check_towers(2)
	# Repopulate lockon dictionaries
	repopulate_post_tower(2)
	spawn_towers_and_rotate()

# Move to bait positions
func move_bait_pos():
	if player_bait:
		move_party_rtd(ForsPositions.BAIT_MIDDLE_POS)
	elif is_future:
		move_party_rtd(ForsPositions.FUTURE_BAIT_POS)
	else:
		move_party_rtd(ForsPositions.PAST_BAIT_POS)


## First All Things Ending cast with clone snapshot
func ending_1_cast():
	ending_cast()

# Move to tower 3 pos
func move_t3_pos():
	move_tower_pos(3)
	
	#match strat:
		#Strat.KB:
			## V1 B=in A=stacks
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_KB, party_a)
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_KB, party_b)
		#Strat.ABBA:
			## V1 B=in A=stacks
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_ABBA, party_baits_a)
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_ABBA, party_b)
		#Strat.RIN, Strat.SOUTH, Strat.EU:
			#move_t1_pos()


## Tower 3 hit, with clones hit
func tower_3_hit():
	clones_cone_hit()
	check_towers(3)
	# Repopulate lockon dictionaries
	repopulate_post_tower(3)
	spawn_towers_and_rotate()

## Cast F/P End 2, hide clones
#future_cast()

# Move to tower 4 pos
func move_t4_pos():
	move_tower_pos(4)
	
	#match strat:
		#Strat.KB:
			## V2 A=in B=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_KB, party_a)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_B_POS_KB, party_baits)
		#Strat.RIN:
			## V2 B=in A=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_UA, party_b)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_UA, party_baits_a)
		#Strat.ABBA:
			## V2 A=in B=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_ABBA, party_a)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_ABBA, party_baits_b)
		#Strat.EU:
			## V2 B=in A=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_EU, party_b)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_EU, party_baits_a)
		#Strat.SOUTH:
			## V2 B=in A=bait
			#move_strat_party_rtd(ForsPositions.V2_IN_POS_OUTTER, party_b)
			#move_strat_party_rtd(ForsPositions.V2_BAIT_POS_OUTTER, party_baits_a)

## Tower 4 hit, spawn clones
func tower_4_hit():
	spawn_clones()
	check_towers(4)
	# Repopulate lockon dictionaries
	repopulate_post_tower(4)
	spawn_towers_and_rotate()

# Move to bait positions
#func move_bait_pos():

## Cast All Things Ending 2
#ending_cast() 

# Move to towers 5 pos
func move_t5_pos():
	move_tower_pos(5)
	
	#match strat:
		#Strat.KB, Strat.ABBA:
			#move_t1_pos()
		#Strat.RIN, Strat.SOUTH:
		## V1 B=in A=stacks
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_UA, party_b)
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_UA, party_baits_a)
		#Strat.EU:
		## V1 B=in A=stacks
			#move_strat_party_rtd(ForsPositions.V1_IN_POS_EU, party_b)
			#move_strat_party_rtd(ForsPositions.V1_STACK_POS_EU, party_baits_a)

## Tower 5 hit, with clones hit
func tower_5_hit():
	clones_cone_hit()
	check_towers(5)
	# Repopulate lockon dictionaries
	repopulate_post_tower(5)
	spawn_towers_and_rotate()

## Cast F/P End 3
#future_cast()

# Move to tower 6 pos
func move_t6_pos():
	move_tower_pos(6)
	
	#match strat:
		#Strat.KB, Strat.ABBA:
			#move_t2_pos()
		#Strat.RIN, Strat.SOUTH, Strat.EU:
			#move_t4_pos()

## Tower 6 hit, spawn clones
func tower_6_hit():
	spawn_clones()
	check_towers(6)
	# Repopulate lockon dictionaries
	repopulate_post_tower(6)
	spawn_towers_and_rotate()

# Move to bait positions

## Cast All Things Ending 3
#ending_cast() 

# Move to towers 7 pos
func move_t7_pos():
	move_tower_pos(7)
	
	#match strat:
		#Strat.KB, Strat.ABBA:
			#move_t3_pos()
		#Strat.RIN, Strat.SOUTH,Strat.EU:
			#move_t5_pos()

## Tower 7 hit, with clones hit
func tower_7_hit():
	clones_cone_hit()
	check_towers(7)
	# Repopulate lockon dictionaries
	repopulate_post_tower(7)
	spawn_towers_and_rotate()

## Cast F/P End 4
#future_cast()

# Move to tower 8 pos
func move_t8_pos():
	move_tower_pos(8)
	
	#match strat:
		#Strat.KB, Strat.ABBA:
			#move_t4_pos()
		#Strat.RIN, Strat.SOUTH, Strat.EU:
			#move_t2_pos()

## Tower 8 hit, spawn clones
func tower_8_hit():
	spawn_clones()
	check_towers(8)
	
	# Repopulate lockon dictionaries
	#if strat == Strat.KB:
		#repopulate_groups(party_a, group_a_keys)

# Move to bait positions

## Cast All Things Ending 4
#ending_cast() 

# Move to final position, safe from baits.
func move_final_pos():
	move_party_rtd(ForsPositions.PAST_BAIT_POS)


## Cast Light of Judgement (for mit check)
func cast_light_judgement():
	cast_bar.cast("Light of Judgement", 4.7)


func ending_cast():
	cast_bar.cast("All Things Ending", 4.7)
	# Clones snapshot 4 random people (needs confirmation)
	var random_keys: Array
	if player_bait:
		random_keys = [player_key, player_key, player_key, player_key]
	else:
		random_keys = lockon_keys.keys()
		random_keys.shuffle()
		random_keys.resize(4)
	assert(clones.size() == 4)
	clone_snapshot_pos.clear()
	for i in 4:
		var target_pos = party[random_keys[i]].global_position
		clone_snapshot_pos.append(v2(target_pos))
		# Turn to target
		if target_pos == clones[i].global_position:
			continue
		var temp_rota := clones[i].get_rotation()
		clones[i].look_at(target_pos + Vector3.UP, Vector3.UP, true)
		var tar_rota := clones[i].get_rotation()
		tar_rota.x = 0
		clones[i].rotation = temp_rota
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(clones[i], "rotation",
		tar_rota, CLONE_TURN_SPEED)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func clones_cone_hit():
	for i in clones.size():
		var clone_pos: Vector2 = v2(clones[i].global_position)
		var target_pos: Vector2 = clone_snapshot_pos[i]
		# If Past's End, clones will shoot opposite from target
		if !is_future:
			target_pos = (target_pos - clone_pos).rotated(deg_to_rad(180)) + clone_pos
		ground_aoe_controller.spawn_cone(clone_pos, CLONE_CONE_ANGLE, CLONE_CONE_LENGTH, target_pos,
			CLONE_CONE_LIFETIME, CLONE_CONE_COLOR, [0, 0, "All Things Ending (Baited Cone)"])
		# For animations, make sure we don't use boss node.
		if clones[i] == boss:
			kefka.cast_kick()
			continue
		clones[i].cast_kick()


func hide_clones():
	for clone in clones:
		if clone == boss:
			continue
		clone.jump_and_hide()


func move_tower_pos(tower_number: int):
	var in_party
	var bait_party
	var in_dict_key
	var bait_dict_key
	var is_even_tower := tower_number % 2 == 0
	var position_strat := even_tower_pos as int if is_even_tower else odd_tower_pos as int
	
	if is_even_tower:
		in_dict_key = "even_tower_in"
		bait_dict_key = "even_tower_soak"
	else:
		in_dict_key = "odd_tower_in"
		bait_dict_key = "odd_tower_soak"
	
	if A_TOWER_SOAKS[soak_order].has(tower_number):
		in_party = party_a
		bait_party = party_baits_b
	else:
		in_party = party_b
		bait_party = party_baits_a
	
	move_strat_party_rtd(POSITION_DICT[in_dict_key][position_strat], in_party)
	move_strat_party_rtd(POSITION_DICT[bait_dict_key][position_strat], bait_party)


func repopulate_post_tower(tower_number: int):
	var soaking_party
	var soaking_group_keys
	if A_TOWER_SOAKS[soak_order].has(tower_number):
		soaking_party = party_a
		soaking_group_keys = group_a_keys
	else:
		soaking_party = party_b
		soaking_group_keys = group_b_keys
	
	repopulate_groups(soaking_party, soaking_group_keys)
	
	#match strat:
		##Strat.KB:
			##repopulate_groups_rmmr(soaking_party, soaking_group_keys)
		#Strat.RIN:
			#repopulate_groups_rmmr(soaking_party, soaking_group_keys)
		#Strat.SOUTH:
			#repopulate_groups_south(soaking_party, soaking_group_keys)
		#Strat.EU, Strat.ABBA:
			#repopulate_groups_rmmr(soaking_party, soaking_group_keys)



# Rotates arena before spawning next pair of towers.
func spawn_towers_and_rotate():
	arena_rotation_deg += 45.0 * rotation_direction
	fr_towers[0] = ground_aoe_controller.spawn_fr_tower(TOWER_POS["north"].rotated(deg_to_rad(arena_rotation_deg)), TOWER_DURATION)
	fr_towers[1] = ground_aoe_controller.spawn_fr_tower(TOWER_POS["east"].rotated(deg_to_rad(arena_rotation_deg)), TOWER_DURATION)


# Casts Future or Past's End and hides clones.
func future_cast():
	if clones.size() > 1:
		hide_clones()
	is_future = randi() % 2 == 0
	if is_future:
		cast_bar.cast("Future's End", 6.2)
		# TODO: Cast Animation
	else:
		cast_bar.cast("Past's End", 6.2)


# After 5s, remove lockons.
func remove_lockons():
	for key in lockon_keys:
		lockon_controller.remove_marker(LOCKON_IDS[lockon_keys[key]], party[key])


# Checks if enough players are in each tower, assigns new lockons based on which tower set, and despawns towers.
func check_towers(tower_set: int):
	# Setup lockons based on tower set
	var new_lockons_keys := even_tower_lockons.duplicate() if tower_set % 2 == 0 else odd_tower_lockons.duplicate()
	new_lockons_keys.shuffle()
	
	for tower: FRTower in fr_towers:
		var bodies_hit: Array[PlayableCharacter] = tower.get_bodies()
		# Check for number of bodies
		if bodies_hit.size() > 2:
			fail_list.add_fail("Too many players soaked tower.")
		elif bodies_hit.size() < 2:
			fail_list.add_fail("Not enough players soaked tower.")
		# Handle lockon and debuff.
		for player_body: PlayableCharacter in bodies_hit:
			if player_body.has_debuff(TROUBLE_DEBUFF):
				var _player_key = player_body.get_role()
				# Trigger lockon hit.
				lockon_trigger(player_body, lockon_keys[_player_key])
				var stacks_remaining = player_body.get_debuff_stacks(TROUBLE_DEBUFF)
				player_body.remove_debuff_stacks(TROUBLE_DEBUFF, 1)
				# If we have more than 4 players hit, repopulate the pool of lockons. Unsure if this matches in-game behavior.
				if new_lockons_keys.is_empty():
					new_lockons_keys = even_tower_lockons.duplicate() if tower_set % 2 == 0 else odd_tower_lockons.duplicate()
					new_lockons_keys.shuffle()
				# If we still have stacks, add new lockon
				if stacks_remaining > 1:
					lockon_keys[_player_key] = new_lockons_keys.pop_back()
					lockon_controller.add_marker(LOCKON_IDS[lockon_keys[_player_key]], player_body)
		# FR Tower should despawn after 11.3s


func lockon_trigger(player_body: PlayableCharacter, lockon: Lockon):
	# Cone
	if lockon == Lockon.CONE:
		# Get nearest player body
		var nearest_pc: PlayableCharacter = get_nearest_other(player_body)
		ground_aoe_controller.spawn_cone(v2(player_body.global_position), CONE_ANGLE_DEG, CONE_LENGTH,
			v2(nearest_pc.global_position), CONE_LIFETIME, CONE_COLOR, [2, 2, "Spellwave (Cone)", [nearest_pc, player_body]])
	# Spread
	elif lockon == Lockon.SPREAD:
		ground_aoe_controller.spawn_circle(v2(player_body.global_position), SPREAD_RADIUS,
			SPREAD_LIFETIME, SPREAD_COLOR, [1, 1, "Spellscatter (Spread)", [player_body]])
	# Stack
	elif lockon == Lockon.STACK:
		ground_aoe_controller.spawn_circle(v2(player_body.global_position), STACK_RADIUS,
			STACK_LIFETIME, STACK_COLOR, [3, 3, "Spelldriver (Stack)"])


# The 4 "clones" include boss. Clones will look at 4 nearest players and charge towards them, 
# with a minimum distance under which they won't move. AoE's will spawn under each player.
func spawn_clones():
	if clones.size() < 4:
		clone_scene = ResourceLoader.load_threaded_get(GOD_KEFKA_UID)
		while clones.size() < 4:
			var new_clone: Node3D = clone_scene.instantiate()
			enemies.add_child(new_clone)
			clones.append(new_clone)
			# Randomly offset clone starting position slightly
			new_clone.global_position = CLONE_POS[clones.size() - 1]
	# Show clones and find nearest players
	var nearest_player_body_keys = get_nearest_player_bodies()
	assert(clones.size() == 4)
	for i in clones.size():
		clones[i].show()
		jump_to_pos_and_hit(clones[i], party[nearest_player_body_keys[i]])


# Jumps the clone to the target position, with a minimum distance at which the clone will not jump.
# Also handles charge animation and jump aoe hit.
func jump_to_pos_and_hit(clone: Node3D, target: PlayableCharacter):
	var target_pos_v3 := target.global_position
	clone.look_at(target_pos_v3 + Vector3.UP, Vector3.UP, true)
	clone.rotation.x = 0
	#clone.rotation.y += deg_to_rad(90.0)
	# Animation and AoE hit
	if clone == boss:
		kefka.cast_charge()
	else:
		clone.cast_charge()
	ground_aoe_controller.spawn_circle(v2(target_pos_v3), CLONE_JUMP_AOE_RADIUS, CLONE_JUMP_AOE_LIFETIME,
		CLONE_JUMP_AOE_COLOR, [1, 1, "Future/Past AoE (Clone bait)", [target]])
	# For now we're not having boss jump for simplicity.
	if clone == boss:
		return
	# We only want to jump to around the edge of the boss' hitbox.
	# If target is not far enough away, don't move.
	if target_pos_v3.length() < CLONE_JUMP_BUFFER:
		target_pos_v3 = target_pos_v3.normalized() * 2.0
	else:
		target_pos_v3 = target_pos_v3.normalized() * (target_pos_v3.length() - CLONE_JUMP_BUFFER)
	# Jump movement tween.
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(clone, "global_position",
		Vector3(target_pos_v3.x, 0, target_pos_v3.z), CLONE_JUMP_DURATION)\
		.set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


# Returns array of containing 4 keys of nearest player bodies to (0, 0)
func get_nearest_player_bodies() -> Array:
	var dist_list := []
	var keys_list := []
	for key in party:
		dist_list.append(v2(party[key].global_position).distance_squared_to(Vector2.ZERO))
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
	# Truncate array down to nearest 4.
	keys_list.resize(4)
	return keys_list


func get_nearest_other(player_body : CharacterBody3D) -> CharacterBody3D:
	var nearest_char: CharacterBody3D
	var nearest_dist_sqrd := 0.0
	for key: String in party:
		var pc: PlayableCharacter = party[key]
		if pc == player_body:
			continue
		var dist := pc.global_position.distance_squared_to(player_body.global_position)
		if nearest_dist_sqrd == 0.0 or dist < nearest_dist_sqrd:
			nearest_char = pc
			nearest_dist_sqrd = dist
	return nearest_char


# Orders the keys by given prio
func order_lr_prio(ordered_keys: Array, keys_to_be_sorted: Array):
	keys_to_be_sorted.sort_custom(func(a, b): return ordered_keys.find(a) < ordered_keys.find(b))


# Returns your group partner
#func get_role_partner_key(role_key: String) -> String:
	#var partner_grp = "1" if role_key.right(1) == "2" else "2"
	#return String(role_key.left(1) + partner_grp)


# Returns your light party partner of opposite role (e.g. t1 + h1)
func get_lp_partner_key(role_key: String) -> String:
	var partner_role = role_key.left(1)
	match partner_role:
		"t":
			return "h" + role_key.right(1)
		"h":
			return "t" + role_key.right(1)
		"m":
			return "r" + role_key.right(1)
		"r":
			return "m" + role_key.right(1)
	assert(false, "You shouldn't be here.")
	return ""


# Make sure the keys in both Dictionaries match.
func move_strat_party_rtd(position_dict: Dictionary, strat_party: Dictionary):
	for key in position_dict:
		if !strat_party.has(key) or strat_party[key] == null:
			continue
		party[strat_party[key]].move_to(position_dict[key].rotated(deg_to_rad(arena_rotation_deg)))


func move_party_rtd(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key].rotated(deg_to_rad(arena_rotation_deg)))


func move_party(position_dict: Dictionary):
	for key in party:
		if position_dict.has(key):
			party[key].move_to(position_dict[key])


func is_dps(key: String) -> bool:
	return Global.DPS_ROLE_KEYS.has(key)


func spawn_test_towers():
	fr_towers.append(ground_aoe_controller.spawn_fr_tower(TOWER_POS["north"], -1.0))
	fr_towers.append(ground_aoe_controller.spawn_fr_tower(TOWER_POS["east"], -1.0))


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
