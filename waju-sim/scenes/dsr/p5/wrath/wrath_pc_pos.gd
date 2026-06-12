# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name P5_Seq1_PC_Positions

static var positions_db := {
	"pre": {
		"t1": Vector2(-37.3, 18.4),
		"t2": Vector2(-37.3, -18.4),
		"def": Vector2(20.5, -36),
		"dive": Vector2(23.1, 34.5),
		"pre1": Vector2(12.9, 39.4),
		"pre2": Vector2(0.0, 41.5),
		"pre3": Vector2(-12.9, 39.4),
		"pre4": Vector2(-23.1, 34.5)
	},
	"cleave": {
		"t1": Vector2(-29, -28.7),
		"t2": Vector2(-8, -40),
		"def": Vector2(13.9, -33.2),
		"dive_gn": Vector2(-41, 0),
		"dive_gs": Vector2(41, 0)
	},
	"post": {
		"l1n": Vector2(26.5, 7.1),
		"l2n": Vector2(26.5, -7.1),
		"stackn": Vector2(9.5, 0.0),
		"l1s": Vector2(-26.5, -7.1),
		"l2s": Vector2(-26.5, 7.1),
		"stacks": Vector2(-9.5, 0.0)
	}
}
