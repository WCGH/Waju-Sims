# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for BoA/Limit Cut sequence.

extends Node

class_name P4Pos


# 'Random' spread values so bots aren't stacked.
const _RS1 := Vector2(0.3, 0.2)
const _RS2 := Vector2(0.15, -0.28)
const _RS3 := Vector2(-0.2, 0.1)

const _MM_NS_WEST := Vector2(-3, 0)
const _MM_NS_EAST := Vector2(3, 0)
const _MM_EW_WEST := Vector2(-2.3, 5.5)
const _MM_EW_EAST := Vector2(2.3, 5.5)
const _MM_NS_WEST_OUT := Vector2(-17, 0)
const _MM_NS_EAST_OUT := Vector2(17, 0)
const _MM_EW_WEST_OUT := Vector2(-6.5, 15.7)
const _MM_EW_EAST_OUT := Vector2(6.5, 15.7)
const _FLOOD_WEST := Vector2(-9, 0)
const _FLOOD_EAST := Vector2(9, 0)
const _DEBUFF_DIST := 25.0
const _TT_NW := Vector2 (-4, -8)
const _TT_NW_GAZE := Vector2 (-2, -3)
const _TT_SW := Vector2 (-4, 8)
const _TT_SW_GAZE := Vector2 (-2, 3)
const _TT_NE := Vector2 (4, -8)
const _TT_NE_GAZE := Vector2 (2, -3)
const _TT_SE := Vector2 (4, 8)
const _TT_SE_GAZE := Vector2 (2, 3)

const MM_NS_WEST_POS := {
	"t1": _MM_NS_WEST + _RS1, "t2": _MM_NS_WEST + _RS2, "h1": _MM_NS_WEST + _RS3, "h2": _MM_NS_WEST,
	"m1": _MM_NS_WEST - _RS1, "m2": _MM_NS_WEST - _RS2, "r1": _MM_NS_WEST - _RS3, "r2": _MM_NS_WEST,
}
const MM_NS_EAST_POS := {
	"t1": _MM_NS_EAST + _RS1, "t2": _MM_NS_EAST + _RS2, "h1": _MM_NS_EAST + _RS3, "h2": _MM_NS_EAST,
	"m1": _MM_NS_EAST - _RS1, "m2": _MM_NS_EAST - _RS2, "r1": _MM_NS_EAST - _RS3, "r2": _MM_NS_EAST,
}
const MM_EW_WEST_POS := {
	"t1": _MM_EW_WEST + _RS1, "t2": _MM_EW_WEST + _RS2, "h1": _MM_EW_WEST + _RS3, "h2": _MM_EW_WEST,
	"m1": _MM_EW_WEST - _RS1, "m2": _MM_EW_WEST - _RS2, "r1": _MM_EW_WEST - _RS3, "r2": _MM_EW_WEST,
}
const MM_EW_EAST_POS := {
	"t1": _MM_EW_EAST + _RS1, "t2": _MM_EW_EAST + _RS2, "h1": _MM_EW_EAST + _RS3, "h2": _MM_EW_EAST,
	"m1": _MM_EW_EAST - _RS1, "m2": _MM_EW_EAST - _RS2, "r1": _MM_EW_EAST - _RS3, "r2": _MM_EW_EAST,
}

# Out is for fake Tsunami on final Magic Release
const MM_NS_WEST_OUT_POS := {
	"t1": _MM_NS_WEST_OUT + _RS1, "t2": _MM_NS_WEST_OUT + _RS2, "h1": _MM_NS_WEST_OUT + _RS3, "h2": _MM_NS_WEST_OUT,
	"m1": _MM_NS_WEST_OUT - _RS1, "m2": _MM_NS_WEST_OUT - _RS2, "r1": _MM_NS_WEST_OUT - _RS3, "r2": _MM_NS_WEST_OUT,
}
const MM_NS_EAST_OUT_POS := {
	"t1": _MM_NS_EAST_OUT + _RS1, "t2": _MM_NS_EAST_OUT + _RS2, "h1": _MM_NS_EAST_OUT + _RS3, "h2": _MM_NS_EAST_OUT,
	"m1": _MM_NS_EAST_OUT - _RS1, "m2": _MM_NS_EAST_OUT - _RS2, "r1": _MM_NS_EAST_OUT - _RS3, "r2": _MM_NS_EAST_OUT,
}
const MM_EW_WEST_OUT_POS := {
	"t1": _MM_EW_WEST_OUT + _RS1, "t2": _MM_EW_WEST_OUT + _RS2, "h1": _MM_EW_WEST_OUT + _RS3, "h2": _MM_EW_WEST_OUT,
	"m1": _MM_EW_WEST_OUT - _RS1, "m2": _MM_EW_WEST_OUT - _RS2, "r1": _MM_EW_WEST_OUT - _RS3, "r2": _MM_EW_WEST_OUT,
}
const MM_EW_EAST_OUT_POS := {
	"t1": _MM_EW_EAST_OUT + _RS1, "t2": _MM_EW_EAST_OUT + _RS2, "h1": _MM_EW_EAST_OUT + _RS3, "h2": _MM_EW_EAST_OUT,
	"m1": _MM_EW_EAST_OUT - _RS1, "m2": _MM_EW_EAST_OUT - _RS2, "r1": _MM_EW_EAST_OUT - _RS3, "r2": _MM_EW_EAST_OUT,
}




const FLOOD_WEST_POS := {
	"t1": _FLOOD_WEST + _RS1, "t2": _FLOOD_WEST + _RS2, "h1": _FLOOD_WEST + _RS3, "h2": _FLOOD_WEST,
	"m1": _FLOOD_WEST - _RS1, "m2": _FLOOD_WEST - _RS2, "r1": _FLOOD_WEST - _RS3, "r2": _FLOOD_WEST,
}
const FLOOD_EAST_POS := {
	"t1": _FLOOD_EAST + _RS1, "t2": _FLOOD_EAST + _RS2, "h1": _FLOOD_EAST + _RS3, "h2": _FLOOD_EAST,
	"m1": _FLOOD_EAST - _RS1, "m2": _FLOOD_EAST - _RS2, "r1": _FLOOD_EAST - _RS3, "r2": _FLOOD_EAST,
}

const DEBUFF_POS := {
	"dps_water": Vector2(0, _DEBUFF_DIST), "sup_water": Vector2(0, -_DEBUFF_DIST),
	"dps_light": Vector2(_DEBUFF_DIST, 0), "sup_light": Vector2(-_DEBUFF_DIST, 0)
}

# For BB + long_debuffs. Do not rotate, positions are static.
const _OFFSET := 4.0
const DEBUFF_POS_NE_SW := {
	"dps_water": Vector2(-_OFFSET, _DEBUFF_DIST), "sup_water": Vector2(_OFFSET, -_DEBUFF_DIST),
	"dps_light": Vector2(_DEBUFF_DIST, -_OFFSET), "sup_light": Vector2(-_DEBUFF_DIST, _OFFSET)
}
const DEBUFF_POS_NW_SE := {
	"dps_water": Vector2(_OFFSET, _DEBUFF_DIST), "sup_water": Vector2(-_OFFSET, -_DEBUFF_DIST),
	"dps_light": Vector2(_DEBUFF_DIST, _OFFSET), "sup_light": Vector2(-_DEBUFF_DIST, -_OFFSET)
}

const TT_WEST_POS := {
	"t1": _TT_NW + _RS1, "t2": _TT_NW + _RS2, "h1": _TT_NW + _RS3, "h2": _TT_NW,
	"m1": _TT_SW - _RS1, "m2": _TT_SW - _RS2, "r1": _TT_SW - _RS3, "r2": _TT_SW,
}
const TT_EAST_POS := {
	"t1": _TT_NE + _RS1, "t2": _TT_NE + _RS2, "h1": _TT_NE + _RS3, "h2": _TT_NE,
	"m1": _TT_SE - _RS1, "m2": _TT_SE - _RS2, "r1": _TT_SE - _RS3, "r2": _TT_SE,
}
const TT_GAZE := {
	"nw": _TT_NW_GAZE, "sw": _TT_SW_GAZE,
	"ne": _TT_NE_GAZE, "se": _TT_SE_GAZE
}

const CENTER_STACK_POS := {
	"t1": Vector2(0, -0.2), "t2": Vector2(0, 0.2),
	"h1": Vector2(-0.2, 0), "h2": Vector2(0.2, 0),
	"m1": Vector2(-0.2, 0.2), "m2": Vector2(0.2, 0.2),
	"r1": Vector2(-0.2, -0.2), "r2": Vector2(0.2, -0.2)
}

const _INFERNO_DIST := 19.0
const INFERNO_DODGE_POS := {
	"t1": Vector2(0, -_INFERNO_DIST) + _RS1, "t2": Vector2(0, -_INFERNO_DIST) + _RS2,
	"h1": Vector2(0, -_INFERNO_DIST) + _RS3, "h2": Vector2(0, -_INFERNO_DIST),
	"m1": Vector2(0, _INFERNO_DIST) - _RS1, "m2": Vector2(0, _INFERNO_DIST) - _RS2,
	"r1": Vector2(0, _INFERNO_DIST) - _RS3, "r2": Vector2(0, _INFERNO_DIST),
}

#
#const CENTER_POS := {
	#"t1": Vector2(0, -2), "t2": Vector2(0, 2),
	#"h1": Vector2(-2, 0), "h2": Vector2(2, 0),
	#"m1": Vector2(-2, 2), "m2": Vector2(2, 2),
	#"r1": Vector2(-2, -2), "r2": Vector2(2, -2)
#}
#
#const EDICT_SLAM_DODGE_POS := {
	#"nw": Vector2(-22, -22), "w": Vector2(-22, 0), "sw": Vector2(-22, 22),
	#"ne": Vector2(22, -22), "e": Vector2(22, 0), "se": Vector2(22, 22)
#}
#
### sg3k
#
## Not rotated
#const EQ_CONGA_POS_KB := {
	#"fil_dps": Vector2(-10, -5), "sil_dps": Vector2(-10, 0), "til_dps": Vector2(-10, 5), "fil_acr": Vector2(0, -5),
	#"fil_sup": Vector2(-5, -5), "sil_sup": Vector2(-5, 0), "til_sup": Vector2(-5, 5), "sil_acr": Vector2(0, 0),
#}
#
## Role stacks
#const LEFT_SLAP_POS := {
	#"t1": Vector2(-13, -13) + RS1, "t2": Vector2(-13, -13) + RS2, "h1": Vector2(-19, 0) + RS3, "h2": Vector2(-19, 0),
	#"m1": Vector2(-13, 13) + RS1, "m2": Vector2(-13, 13) + RS2, "r1": Vector2(-13, 13) + RS3, "r2": Vector2(-13, 13),
#}
#
#const RIGHT_SLAP_POS := {
	#"t1": Vector2(19, 0) + RS1, "t2": Vector2(19, 0) + RS2, "h1": Vector2(19, 0) + RS3, "h2": Vector2(19, 0),
	#"m1": Vector2(19, 0) - RS1, "m2": Vector2(19, 0) - RS2, "r1": Vector2(19, 0) - RS3, "r2": Vector2(19, 0),
#}
#
## First movement is to simlulate grabbing tether before rotating CW. 0 = North, 1 = East, 2 = South
#const BH_PRE_POS := {0: Vector2(0, -16), 1: Vector2(16, 0), 2: Vector2(0, 16)}
#
#const BH_BAIT_POS := {0: Vector2(14, -10), 1: Vector2(10, 14), 2: Vector2(-14, 10)}
#
## NE
#const LAT_RIGHT_POS := {
	#"t1": Vector2(16, -8.5) + RS1, "t2": Vector2(16, -8.5) + RS2, "h1": Vector2(16, -8.5) + RS3, "h2": Vector2(16, -8.5),
	#"m1": Vector2(16, -8.5) - RS1, "m2": Vector2(16, -8.5) - RS2, "r1": Vector2(16, -8.5) - RS3, "r2": Vector2(16, -8.5),
#}
## SE
#const LONG_RIGHT_POS := {
	#"t1": Vector2(16, 8.5) + RS1, "t2": Vector2(16, 8.5) + RS2, "h1": Vector2(16, 8.5) + RS3, "h2": Vector2(16, 8.5),
	#"m1": Vector2(16, 8.5) - RS1, "m2": Vector2(16, 8.5) - RS2, "r1": Vector2(16, 8.5) - RS3, "r2": Vector2(16, 8.5),
#}
## NW
#const LONG_LEFT_POS := {
	#"t1": Vector2(-16, -8.5) + RS1, "t2": Vector2(-16, -8.5) + RS2, "h1": Vector2(-16, -8.5) + RS3, "h2": Vector2(-16, -8.5),
	#"m1": Vector2(-16, -8.5) - RS1, "m2": Vector2(-16, -8.5) - RS2, "r1": Vector2(-16, -8.5) - RS3, "r2": Vector2(-16, -8.5),
#}
## SW
#const LAT_LEFT_POS := {
	#"t1": Vector2(-16, 8.5) + RS1, "t2": Vector2(-16, 8.5) + RS2, "h1": Vector2(-16, 8.5) + RS3, "h2": Vector2(-16, 8.5),
	#"m1": Vector2(-16, 8.5) - RS1, "m2": Vector2(-16, 8.5) - RS2, "r1": Vector2(-16, 8.5) - RS3, "r2": Vector2(-16, 8.5),
#}
#
#const BLIZZARD_PAIRS_POS := {
	#"t1": Vector2(-11, -11) + RS1, "t2": Vector2(11, -11) + RS2, "h1": Vector2(-11, -11), "h2": Vector2(11, -11),
	#"m1": Vector2(-11, 11) - RS1, "m2": Vector2(11, 11) - RS2, "r1": Vector2(-11, 11), "r2": Vector2(11, 11),
#}
#
#const SUP_TOWER_POS := {
	#"t1": Vector2(-18, 0) + RS1, "t2": Vector2(18, 0) + RS2, "h1": Vector2(-18, 0), "h2": Vector2(18, 0),
	#"m1": Vector2(-0.3, 0.1) - RS1, "m2": Vector2(0.2, 0.1) - RS2, "r1": Vector2(0, -0.3), "r2": Vector2(0, 0.2),
#}
#
#const DPS_TOWER_POS := {
	#"m1": Vector2(-18, 0) + RS1, "m2": Vector2(18, 0) + RS2, "r1": Vector2(-18, 0), "r2": Vector2(18, 0),
	#"t1": Vector2(-0.3, 0.1) - RS1, "t2": Vector2(0.2, 0.1) - RS2, "h1": Vector2(0, -0.3), "h2": Vector2(0, 0.2),
#}
