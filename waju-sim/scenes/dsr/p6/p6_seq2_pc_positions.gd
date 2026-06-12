# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name P6_Seq2_PC_Positions

static var pc_positions := {
	"wyrm1": {
		"heal": Vector2(-9.77, 38.78),
		"ranged": Vector2(9.77, 38.78),
		"melee": Vector2(0, 17.45),
		"tanks": Vector2(0, -6),
		"t1": Vector2(-31.28, -24.58),
		"t2": Vector2(31.28, -24.58)
	},
	"vow1": {
		"t1": Vector2(-5.95, -13.62),
		"t2": Vector2(5.95, -13.62),
		"h1": Vector2(0, -9),
		"h2": Vector2(0, 9),
		"m1": Vector2(-19, 8),
		"m2": Vector2(19, 8),
		"r1": Vector2(-14.6, 24),
		"r2": Vector2(14.6, 24)
	},
	"aa": {
		"lp1": Vector2(0, -9),
		"lp2": Vector2(0, 9)
	},
	"wings1": {
		"ne": {
			"t_near" : {
				"t1": Vector2(40, -25),
				"t2": Vector2(33, -3),
				"pt": Vector2(10, -22)
			},
			"t_far" : {
				"t1": Vector2(5, -40),
				"t2": Vector2(5, -5),
				"pt": Vector2(40, -5)
			},
		},
		"nw": {
			"t_near" : {
				"t1": Vector2(-5, -40),
				"t2": Vector2(-5, -5),
				"pt": Vector2(-30, -30)
			},
			"t_far" : {
				"t1": Vector2(-25, -25),
				"t2": Vector2(-40, -5),
				"pt": Vector2(-5, -5)
			},
		},
		"se": {
			"t_near" : {
				"t1": Vector2(30, 3),
				"t2": Vector2(40, 25),
				"pt": Vector2(10, 22)
			},
			"t_far" : {
				"t1": Vector2(5, 5),
				"t2": Vector2(5, 40),
				"pt": Vector2(40, 5)
			},
		},
		"sw": {
			"t_near" : {
				"t1": Vector2(-5, 5),
				"t2": Vector2(-5, 30),
				"pt": Vector2(-30, 30)
			},
			"t_far" : {
				"t1": Vector2(-40, 5),
				"t2": Vector2(-40, 40),
				"pt": Vector2(-5, 5)
			},
		}
	},
	"vow2": {
		"north": {
		"t1": Vector2(0, -1),
		"t2": Vector2(20, -18),
		"h1": Vector2(-4, -16),
		"h2": Vector2(4, -16),
		"m1": Vector2(-11, -18),
		"m2": Vector2(11, -18),
		"r1": Vector2(2, -20),
		"r2": Vector2(-3, -24)
		},
		"south": {
		"t1": Vector2(0, 1),
		"t2": Vector2(20, 18),
		"h1": Vector2(-4, 16),
		"h2": Vector2(4, 16),
		"m1": Vector2(-11, 18),
		"m2": Vector2(11, 18),
		"r1": Vector2(2, 20),
		"r2": Vector2(-3, 24)
		}
	}
}
