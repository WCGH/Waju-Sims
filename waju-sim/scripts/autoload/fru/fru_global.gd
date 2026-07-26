# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

#
#const MAIN_UIDS = {
	#Encounter.FRU: "uid://cmwfv2pm71awx",
	#Encounter.DSR: "",
	#Encounter.DMU: ""}
#
#const TANKS = ["Tank 1", "Tank 2"]
#const HEALERS = ["Healer 1", "Healer 2"]
#const MELEE = ["Melee 1", "Melee 2"]
#const RANGED = ["Ranged 1", "Ranged 2"]
#const SUPPORT = TANKS + HEALERS
#const DPS = MELEE + RANGED
#const ALL_ROLES = SUPPORT + DPS
#const ROLE_GROUP_NAMES = {"Tank": TANKS, "Healer": HEALERS, "DPS": DPS}
#const ROLE_KEYS = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
#const DPS_ROLE_KEYS = ["m1", "m2", "r1", "r2"]
#const TANK_ROLE_KEYS = ["t1", "t2"]
#const HEALER_ROLE_KEYS = ["h1", "h2"]
#const ROLE_NAMES = {"t1": TANKS[0], "t2": TANKS[1],
	#"h1": HEALERS[0], "h2": HEALERS[1],
	#"m1": MELEE[0], "m2": MELEE[1],
	#"r1": RANGED[0], "r2": RANGED[1]}

# General
#var encounter: Encounter
#var main_uid := ""
#var debug := false
#var deathwall_active := true
#var player_role_key : String
#var selected_role_index := 4
#var selected_sequence_index := 0
#var spectate_mode := false
#var is_moving_ui := false

## FRU settings
## These have been moved to global_fru but are kept here for redundancy.
# P2 Light Rampant
var p2_force_puddles := false

# P3 Ultimate Relativity
var p3_selected_debuff := 0  # [random, short, med, long]
var p3_ur_hide_bots := false

# P3 Apoc
var p3_t1_bait := false
var p3_apoc_force_swap := false

# P4 Darklit Dragonsong
var p4_dd_force_tether := false
var p4_dd_force_spirit := false

# P4 Crystallize Time
var p4_ct_selected_debuff := 0  # [random, red/aero, red/ice, blue/eruption, blue/ice, blue,unholy, blue/water]
var p4_ct_force_spirit := false
var p4_ct_hide_bots := false

# P5 Pandora
var p5_selected_seq := 0 # [Fulgent Blade, Paradise Regained, Polarizing Strikes]
var p5_ew_hide_bots := false

# FRU Waymarks
var waymarks := {
	"preset_1": {
		"name": "Inner (NA/EU)",
		"wm_a": Vector2(22, 0), "wm_b": Vector2(0, 22), "wm_c": Vector2(-22, 0), "wm_d": Vector2(0, -22),
		"wm_1": Vector2(15.554, -15.554), "wm_2": Vector2(15.554, 15.554), "wm_3": Vector2(-15.554, 15.554), "wm_4": Vector2(-15.554, -15.554),
	},
	"preset_2": {
		"name": "Outter",
		"wm_a": Vector2(26, 0), "wm_b": Vector2(0, 26), "wm_c": Vector2(-26, 0), "wm_d": Vector2(0, -26),
		"wm_1": Vector2(18.38, -18.38), "wm_2": Vector2(18.38, 18.38), "wm_3": Vector2(-18.38, 18.38), "wm_4": Vector2(-18.38, -18.38),
	},
	"preset_3": {
		"name": "Far Out",
		"wm_a": Vector2(40, 0), "wm_b": Vector2(0, 40), "wm_c": Vector2(-40, 0), "wm_d": Vector2(0, -40),
		"wm_1": Vector2(28.28, -28.28), "wm_2": Vector2(28.28, 28.28), "wm_3": Vector2(-28.28, 28.28), "wm_4": Vector2(-28.28, -28.28),
	},
	"current": {}
}
