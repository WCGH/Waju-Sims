# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

#P3
var p3_in_line := 0  # [Random, 1, 2, 3]
var p3_arrow := 0    # [Random, Up, Circle, Down]
# P5
var player_puddles := false
var rare_death_pattern := false
var default_lineup := ["r1", "m1", "t1", "h1", "h2", "t2", "m2", "r2"]
# P6
var p6_selected_seq := 0 # [WBreath 1, Wings 1, Wroth, Wings 2, WBreath 2]
var hide_bots := false
var vow_target_key := ""

# DSR Waymarks
var waymarks := {
	# NAUR Markers
	"preset_1": {
		"name": "NAUR",
		"wm_a": Vector2(0, -19), "wm_b": Vector2(26, -26), "wm_c": Vector2(19, 0), "wm_d": Vector2(26, 26),
		"wm_1": Vector2(0, 19), "wm_2": Vector2(-26, 26), "wm_3": Vector2(-19, 0), "wm_4": Vector2(-26, -26),
	},
	"preset_2": {
		"name": "LPDU",
		"wm_1": Vector2(0, 38.95), "wm_2": Vector2(-27.24, 26.69), "wm_3": Vector2(-37.92, 0), "wm_4": Vector2(-27, -26.36),
		"wm_a": Vector2(0, -38.17), "wm_b": Vector2(26.97, -27.11), "wm_c": Vector2(38.03, 0), "wm_d": Vector2(27.544, 27.44)
	},
	"preset_3": {
		"name": "NAUR (P3/Flipped)",
		"wm_a": Vector2(0, 19), "wm_b": Vector2(-26, 26), "wm_c": Vector2(-19, 0), "wm_d": Vector2(-26, -26),
		"wm_1": Vector2(0, -19), "wm_2": Vector2(26, -26), "wm_3": Vector2(19, 0), "wm_4": Vector2(26, 26),
	},
	"current": {}
}
