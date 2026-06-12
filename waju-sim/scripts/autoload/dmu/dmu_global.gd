# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

## DMU settings
## P2 Light Rampant
#var p2_force_puddles := false


# DMU Preset Waymarks
var waymarks := {
	"preset_1": {
		"name": "Diamond",
		"wm_1": Vector2(-13.8, -13.8), "wm_2": Vector2(13.8, -13.8), "wm_3": Vector2(13.8, 13.8), "wm_4": Vector2(-13.8, 13.8),
		"wm_a": Vector2(0, -27.6), "wm_b": Vector2(27.6, 0), "wm_c": Vector2(0, 27.6), "wm_d": Vector2(-27.6, 0)
	},
	"preset_2": {
		"name": "Cross (X13)",
		"wm_1": Vector2(-14.955397, -14.955397), "wm_2": Vector2(14.955397, -14.955397),
		"wm_3": Vector2(14.955397, 14.955397), "wm_4": Vector2(-14.955397, 14.955397),
		"wm_a": Vector2(-28.24936, -28.24936), "wm_b": Vector2(28.24936, -28.24936),
		"wm_c": Vector2(28.24936, 28.24936),"wm_d": Vector2(-28.24936, 28.24936)
	},
	"preset_3": {
		"name": "Circle",
		"wm_1": Vector2(-21.15, -21.15), "wm_2": Vector2(21.15, -21.15), "wm_3": Vector2(21.15, 21.15), "wm_4": Vector2(-21.15, 21.15),
		"wm_a": Vector2(0, -29.375), "wm_b": Vector2(29.375, 0), "wm_c": Vector2(0, 29.375), "wm_d": Vector2(-29.375, 0)
	},
	"current": {}
}
