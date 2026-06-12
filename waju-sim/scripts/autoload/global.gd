# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

enum Encounter {FRU, DSR, DMU}

const MAIN_UIDS = {
	Encounter.FRU: "uid://cmwfv2pm71awx",
	Encounter.DSR: "uid://cu0wjulfrlu1h",
	Encounter.DMU: "uid://grvodnsxbtm4"}

const TANKS = ["Tank 1", "Tank 2"]
const HEALERS = ["Healer 1", "Healer 2"]
const MELEE = ["Melee 1", "Melee 2"]
const RANGED = ["Ranged 1", "Ranged 2"]
const SUPPORT = TANKS + HEALERS
const DPS = MELEE + RANGED
const ALL_ROLES = SUPPORT + DPS
const ROLE_GROUP_NAMES = {"Tank": TANKS, "Healer": HEALERS, "DPS": DPS}
const ROLE_KEYS = ["t1", "t2", "h1", "h2", "m1", "m2", "r1", "r2"]
const DPS_ROLE_KEYS = ["m1", "m2", "r1", "r2"]
const SUP_ROLE_KEYS = ["t1", "t2", "h1", "h2"]
const TANK_ROLE_KEYS = ["t1", "t2"]
const HEALER_ROLE_KEYS = ["h1", "h2"]
const MELEE_ROLE_KEYS = ["m1", "m2"]
const RANGED_ROLE_KEYS = ["r1", "r2"]
const ROLE_NAMES = {"t1": TANKS[0], "t2": TANKS[1],
	"h1": HEALERS[0], "h2": HEALERS[1],
	"m1": MELEE[0], "m2": MELEE[1],
	"r1": RANGED[0], "r2": RANGED[1]}

# General
var encounter: Encounter
var main_uid := ""
var debug := false
var deathwall_active := true
var player_role_key : String
var selected_role_index := 4
var selected_sequence_index := 0
var spectate_mode := false
var is_moving_ui := false
var hide_bots := false
var current_focus_key := ""


func get_encounter_waymarks() -> Dictionary:
	match encounter:
		Encounter.FRU:
			return FruGlobal.waymarks
		Encounter.DSR:
			return DsrGlobal.waymarks
		Encounter.DMU:
			return DmuGlobal.waymarks
	push_error("You shouldn't be here.")
	return {}


func set_encounter_waymarks(waymarks: Dictionary):
	match encounter:
		Encounter.FRU:
			FruGlobal.waymarks["current"] = waymarks
		Encounter.DSR:
			DsrGlobal.waymarks["current"] = waymarks
		Encounter.DMU:
			DmuGlobal.waymarks["current"] = waymarks
	return


func set_encounter(encounter_enum: Encounter):
	encounter = encounter_enum
	main_uid = MAIN_UIDS[encounter]


# Global Utility Functions

func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)
