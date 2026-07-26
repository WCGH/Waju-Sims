# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for BoA/Limit Cut sequence.

extends Node

class_name EqPos


# 'Random' spread values so bots aren't stacked.
const RS1 := Vector2(0.3, 0.2)
const RS2 := Vector2(0.15, -0.28)
const RS3 := Vector2(-0.2, 0.1)


const CENTER_POS := {
	"t1": Vector2(0, -2), "t2": Vector2(0, 2),
	"h1": Vector2(-2, 0), "h2": Vector2(2, 0),
	"m1": Vector2(-2, 2), "m2": Vector2(2, 2),
	"r1": Vector2(-2, -2), "r2": Vector2(2, -2)
}

const CENTER_STACK_POS := {
	"t1": Vector2(0, -0.2), "t2": Vector2(0, 0.2),
	"h1": Vector2(-0.2, 0), "h2": Vector2(0.2, 0),
	"m1": Vector2(-0.2, 0.2), "m2": Vector2(0.2, 0.2),
	"r1": Vector2(-0.2, -0.2), "r2": Vector2(0.2, -0.2)
}

const EDICT_SLAM_DODGE_POS := {
	"nw": Vector2(-22, -22), "w": Vector2(-22, 0), "sw": Vector2(-22, 22),
	"ne": Vector2(22, -22), "e": Vector2(22, 0), "se": Vector2(22, 22)
}

## sg3k

# Not rotated
const EQ_CONGA_POS_KB := {
	"fil_dps": Vector2(-10, -5), "sil_dps": Vector2(-10, 0), "til_dps": Vector2(-10, 5), "fil_acr": Vector2(0, -5),
	"fil_sup": Vector2(-5, -5), "sil_sup": Vector2(-5, 0), "til_sup": Vector2(-5, 5), "sil_acr": Vector2(0, 0),
}

# Role stacks
const LEFT_SLAP_POS := {
	"t1": Vector2(-13, -13) + RS1, "t2": Vector2(-13, -13) + RS2, "h1": Vector2(-19, 0) + RS3, "h2": Vector2(-19, 0),
	"m1": Vector2(-13, 13) + RS1, "m2": Vector2(-13, 13) + RS2, "r1": Vector2(-13, 13) + RS3, "r2": Vector2(-13, 13),
}

const RIGHT_SLAP_POS := {
	"t1": Vector2(19, 0) + RS1, "t2": Vector2(19, 0) + RS2, "h1": Vector2(19, 0) + RS3, "h2": Vector2(19, 0),
	"m1": Vector2(19, 0) - RS1, "m2": Vector2(19, 0) - RS2, "r1": Vector2(19, 0) - RS3, "r2": Vector2(19, 0),
}

# First movement is to simlulate grabbing tether before rotating CW. 0 = North, 1 = East, 2 = South
const BH_PRE_POS := {0: Vector2(0, -16), 1: Vector2(16, 0), 2: Vector2(0, 16)}

const BH_BAIT_POS := {0: Vector2(14, -10), 1: Vector2(10, 14), 2: Vector2(-14, 10)}

# NE
const LAT_RIGHT_POS := {
	"t1": Vector2(16, -8.5) + RS1, "t2": Vector2(16, -8.5) + RS2, "h1": Vector2(16, -8.5) + RS3, "h2": Vector2(16, -8.5),
	"m1": Vector2(16, -8.5) - RS1, "m2": Vector2(16, -8.5) - RS2, "r1": Vector2(16, -8.5) - RS3, "r2": Vector2(16, -8.5),
}
# SE
const LONG_RIGHT_POS := {
	"t1": Vector2(16, 8.5) + RS1, "t2": Vector2(16, 8.5) + RS2, "h1": Vector2(16, 8.5) + RS3, "h2": Vector2(16, 8.5),
	"m1": Vector2(16, 8.5) - RS1, "m2": Vector2(16, 8.5) - RS2, "r1": Vector2(16, 8.5) - RS3, "r2": Vector2(16, 8.5),
}
# NW
const LONG_LEFT_POS := {
	"t1": Vector2(-16, -8.5) + RS1, "t2": Vector2(-16, -8.5) + RS2, "h1": Vector2(-16, -8.5) + RS3, "h2": Vector2(-16, -8.5),
	"m1": Vector2(-16, -8.5) - RS1, "m2": Vector2(-16, -8.5) - RS2, "r1": Vector2(-16, -8.5) - RS3, "r2": Vector2(-16, -8.5),
}
# SW
const LAT_LEFT_POS := {
	"t1": Vector2(-16, 8.5) + RS1, "t2": Vector2(-16, 8.5) + RS2, "h1": Vector2(-16, 8.5) + RS3, "h2": Vector2(-16, 8.5),
	"m1": Vector2(-16, 8.5) - RS1, "m2": Vector2(-16, 8.5) - RS2, "r1": Vector2(-16, 8.5) - RS3, "r2": Vector2(-16, 8.5),
}

const BLIZZARD_PAIRS_POS := {
	"t1": Vector2(-11, -11) + RS1, "t2": Vector2(11, -11) + RS2, "h1": Vector2(-11, -11), "h2": Vector2(11, -11),
	"m1": Vector2(-11, 11) - RS1, "m2": Vector2(11, 11) - RS2, "r1": Vector2(-11, 11), "r2": Vector2(11, 11),
}

const SUP_TOWER_POS := {
	"t1": Vector2(-18, 0) + RS1, "t2": Vector2(18, 0) + RS2, "h1": Vector2(-18, 0), "h2": Vector2(18, 0),
	"m1": Vector2(-0.3, 0.1) - RS1, "m2": Vector2(0.2, 0.1) - RS2, "r1": Vector2(0, -0.3), "r2": Vector2(0, 0.2),
}

const DPS_TOWER_POS := {
	"m1": Vector2(-18, 0) + RS1, "m2": Vector2(18, 0) + RS2, "r1": Vector2(-18, 0), "r2": Vector2(18, 0),
	"t1": Vector2(-0.3, 0.1) - RS1, "t2": Vector2(0.2, 0.1) - RS2, "h1": Vector2(0, -0.3), "h2": Vector2(0, 0.2),
}
