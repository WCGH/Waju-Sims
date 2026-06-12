# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

enum Intercards {NW, NE, SE, SW}
enum Strat {NA, EU}

# Debuff Icon Scenes
const AERO_ICON = preload("uid://dyog4h7k3ofek")

# AoE Dimensions
const AERO_RADIUS := 27.2
const AERO_LIFETIME := 0.2
const AERO_COLOR := Color(0.612, 0.882, 0.776, 0.903)

# Lineup Prio
const NA_WE_PRIO := ["h2", "h1", "t2", "t1", "m1", "m2", "r1", "r2"]
# NPC Positions
const USURPER_POS := {
	"e": Vector3(0, 0, 48.0), "e_rota": 180.0,
	"w": Vector3(0, 0, -48.0), "w_rota": 0.0,
	"n": Vector3(48.0, 0, 0), "n_rota": -90.0,
	"s": Vector3(-48.0, 0, 0), "s_rota": 90.0,
	"mid": Vector3(0, 0, 0), "mid_rota": -90.0,
	"final": Vector3(0, 0, -6), "final_rota": -135.0
}

@onready var encounter_anim_tmpl: AnimationPlayer = %EncounterAnimTmpl
@onready var cast_bar: CastBar = %CastBar
@onready var clone_cast_bar: CloneCastBar = %CloneCastBar
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var lockon_controller: LockonController = %LockonController
#@onready var kefka: Node3D = %Kefka

var party: Dictionary
var party_ct := {
	"r_aero_sw": "", "r_aero_se": "",
	"r_ice_w": "", "r_ice_e": "",
	"b_erupt": "", "b_ice": "", "b_ud": "", "b_water": ""
	}
var strat: Strat
var user_setting

func start_sequence(new_party: Dictionary) -> void:
	assert(new_party != null, "Error. Where the party at?")
	#ground_aoe_controller.preload_aoe(["line", "circle", "donut"])
	## Get Strat.
	#strat = FruSavedVariables.save_data["settings"]["p4_ct_strat"]
	#if strat is not int or strat >= Strat.size() or strat < 0:
		## Fix invalid SavedVariables, defaults to NA.
		#GameEvents.emit_encounter_variable_saved("settings", "p4_ct_strat", 0)
		#strat = Strat.NA
	## Apply user settings
	#user_setting = FruSavedVariables.save_data["settings"]["p4_ct_aero_plant"]
	
	# instantiate_party(new_party)
	## Start animation sequence
	#encounter_anim_tmpl.play("tmpl_anim")


### START OF TIMELINE ###

## 0.00


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)


func v3(vec2: Vector2) -> Vector3:
	return Vector3(vec2.x, 0, vec2.y)
