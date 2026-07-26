# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name P6_NPC_Positions

static var npc_positions := {
	"nid_spawn": Vector2(-50, 0),
	"hra_spawn": Vector2(50, 0),
	"db": {
		"ne": Vector2(22.5, -73), "nw": Vector2(-22.5, -73), "n": Vector2(0, -73),
		"se": Vector2(22.5, 73), "sw": Vector2(-22.5, 73), "s": Vector2(0, 73)
	},
	"wings": {
		"ne": Vector2(50, -22.5), "nw": Vector2(-50, -22.5),
		"se": Vector2(50, 22.5),"sw": Vector2(-50, 22.5)
	},
	"north_wing": Vector2(-50, -27),
	"north_wing_tar": Vector2(50, -27),
	"south_wing": Vector2(-50, 27),
	"south_wing_tar": Vector2(50, 27)
}
