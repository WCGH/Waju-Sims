# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name P5_Seq2_PC_Positions

static var positions_db := {
	"lineup": {
		"0": Vector2(0, -14),
		"1": Vector2(0, -10),
		"2": Vector2(0, -6),
		"3": Vector2(0, -2),
		"4": Vector2(0, 2),
		"5": Vector2(0, 6),
		"6": Vector2(0, 10),
		"7": Vector2(0, 14)
	},
	"doom_lineup": {
		"doom1": Vector2(4.5, -10),
		"doom2": Vector2(4.5, -3.5),
		"doom3": Vector2(4.5, 3.5),
		"doom4": Vector2(4.5, 10),
		"free1": Vector2(-2.5, -10),
		"free2": Vector2(-2.5, -3.5),
		"free3": Vector2(-2.5, 3.5),
		"free4": Vector2(-2.5, 10)
	},
	"impact_1": {
		"doom1": Vector2(0, -27),
		"doom2": Vector2(30.86, -27.92),
		"doom3": Vector2(30.86, 27.92),
		"doom4": Vector2(0, 27),
		"free1": Vector2(0, -41),
		"free2": Vector2(-30.86, -27.92),
		"free3": Vector2(-30.86, 27.92),
		"free4": Vector2(0, 41)
	},
	"impact_2": {
		"doom1": Vector2(0, -10),
		"doom2": Vector2(-2.5, -2.5),
		"doom3": Vector2(-2.5, 2.5),
		"doom4": Vector2(0, 10),
		"free1": Vector2(-13.21, -31.38),
		"free2": Vector2(-13.21, -31.38),
		"free3": Vector2(-13.21, 31.38),
		"free4": Vector2(-13.21, 31.38)
	},
	"impact_3": {
		"doom1": Vector2(0, -10),
		"doom2": Vector2(-2.5, -2.5),
		"doom3": Vector2(-2.5, 2.5),
		"doom4": Vector2(0, 10),
		"free1": Vector2(2.5, 0),
		"free2": Vector2(2.5, -2.5),
		"free3": Vector2(2.5, 2.5),
		"free4": Vector2(-2.5, 0)
	},
	"ps2": {
		"cross1": Vector2(2.5, 0),
		"cross2": Vector2(-2.5, 0),
		"circle1": Vector2(0, -2.5),
		"circle2": Vector2(0, 2.5),
		"triangle1" : Vector2(2.5, -2.5),
		"triangle2" : Vector2(-2.5, 2.5),
		"square1" : Vector2(2.5, 2.5),
		"square2" : Vector2(-2.5, -2.5)
	},
	"ps2_anchor": {
		"cross1": Vector2(2.5, 0),
		"cross2": Vector2(-2.5, 0),
		"circle1": Vector2(0, -2.5),
		"circle2": Vector2(0, 2.5),
		"flex3" : Vector2(2.5, -2.5),
		"doom3" : Vector2(-2.5, 2.5),
		"flex2" : Vector2(2.5, 2.5),
		"doom2" : Vector2(-2.5, -2.5)
	},
	"post_kb": {
		"cross1": Vector2(40, 0),
		"cross2": Vector2(-40, 0),
		"circle1": Vector2(0, -41),
		"circle2": Vector2(0, 41),
		"triangle1" : Vector2(28, -28),
		"triangle2" : Vector2(-30.86, 27.92),
		"square1" : Vector2(28, 28),
		"square2" : Vector2(-30.86, -27.92)
	},
	"other": {
		"east_bait": Vector2(0, -8),
		"far_north": Vector2(200, 0)
	}
}
