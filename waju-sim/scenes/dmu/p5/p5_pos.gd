# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for BoA/Limit Cut sequence.

extends Node

class_name P5Pos


# 'Random' spread values so bots aren't stacked.
const _RS1 := Vector2(0.3, 0.2)
const _RS2 := Vector2(0.15, -0.28)
const _RS3 := Vector2(-0.2, 0.1)


# Autos
const _AUTO_N := Vector2(0, -18.0)
const _AUTO_SE := Vector2(13.5, 13.5)
const _AUTO_SW := Vector2(-13.5, 13.5)


const AUTO_POS := {
	"t1": _AUTO_N + _RS1, "t2": _AUTO_N, "h1": _AUTO_SW + _RS1, "h2": _AUTO_SW,
	"m1": _AUTO_SE + _RS1, "m2": _AUTO_SE + _RS2, "r1": _AUTO_SE + _RS3, "r2": _AUTO_SE,
}


# Flood
const _FLOOD_SW := Vector2(-4, 4)
const _FLOOD_NW := Vector2(-4, -4)
const _FLOOD_NE := Vector2(4, -4)
const _FLOOD_SE := Vector2(4, 4)

const FLOOD_SW := {
	"t1": _FLOOD_SW + _RS1, "t2": _FLOOD_SW + _RS2, "h1": _FLOOD_SW + _RS3, "h2": _FLOOD_SW,
	"m1": _FLOOD_SW - _RS1, "m2": _FLOOD_SW - _RS2, "r1": _FLOOD_SW - _RS3, "r2": _FLOOD_SW,
}

const FLOOD_SE := {
	"t1": _FLOOD_SE + _RS1, "t2": _FLOOD_SE + _RS2, "h1": _FLOOD_SE + _RS3, "h2": _FLOOD_SE,
	"m1": _FLOOD_SE - _RS1, "m2": _FLOOD_SE - _RS2, "r1": _FLOOD_SE - _RS3, "r2": _FLOOD_SE,
}

const FLOOD_NW := {
	"t1": _FLOOD_NW + _RS1, "t2": _FLOOD_NW + _RS2, "h1": _FLOOD_NW + _RS3, "h2": _FLOOD_NW,
	"m1": _FLOOD_NW - _RS1, "m2": _FLOOD_NW - _RS2, "r1": _FLOOD_NW - _RS3, "r2": _FLOOD_NW,
}

const FLOOD_NE := {
	"t1": _FLOOD_NE + _RS1, "t2": _FLOOD_NE + _RS2, "h1": _FLOOD_NE + _RS3, "h2": _FLOOD_NE,
	"m1": _FLOOD_NE - _RS1, "m2": _FLOOD_NE - _RS2, "r1": _FLOOD_NE - _RS3, "r2": _FLOOD_NE,
}


# Maddening
const _MAD_TANK_N := Vector2(0, -23)
const _MAD_TANK_FAR_N := Vector2(0, -45)

const MAD_PRE_POS := {
	"t1": Vector2(-8.8, -21.25), "t2": Vector2(8.8, -21.25), "h1": Vector2(-22.65, -4), "h2": Vector2(-18, 15),
	"m1": Vector2(-5, 23), "m2": Vector2(10.84, 20.28), "r1": Vector2(21.25, 8.8), "r2": Vector2(21.25, -8.8),
}

const MAD_2_TANK_POS := {
	"t1": _MAD_TANK_N + _RS1, "t2": _MAD_TANK_N - _RS1
}

const MAD_3_TANK_POS := {
	"mt": _MAD_TANK_FAR_N, "ot": _MAD_TANK_N,
}

const MAD_3_PARTY_POS := {
	"h1": Vector2(-27, 16), "h2": Vector2(-15, 20),
	"m1": Vector2(-6, 22), "m2": Vector2(6, 22),
	"r1": Vector2(20, 19), "r2": Vector2(32, 15),
}

# Stray Entropy (Exaflare spread)
const EXA_SPREAD_POS := {
	"t1": Vector2(-10.33, -24.94), "t2": Vector2(10.33, -24.94), "h1": Vector2(-24.94, -10.33), "h2": Vector2(-24.94, 10.33),
	"m1": Vector2(-10.33, 24.94), "m2": Vector2(10.33, 24.94), "r1": Vector2(24.94, 10.33), "r2": Vector2(24.94, -10.33),
}


# Forsaken
const _FORS_S := Vector2(0, 23)
const _FORS_W := Vector2(-23, 0)
const _FORS_N := Vector2(0, -23)
const _FORS_E := Vector2(23, 0)
const _FORS_SW_OVER := Vector2(-17.62, 14.78)
const _FORS_SW := Vector2(-16.26, 16.26)
const _FORS_NW := Vector2(-16.26, -16.26)
const _FORS_NE := Vector2(16.26, -16.26)
const _FORS_SE := Vector2(16.26, 16.26)

const FORS_S_POS := {
	"t1":_FORS_S + _RS1, "t2":_FORS_S + _RS2, "h1":_FORS_S + _RS3, "h2":_FORS_S,
	"m1":_FORS_S - _RS1, "m2":_FORS_S - _RS2, "r1":_FORS_S - _RS3, "r2":_FORS_S,
}

const FORS_W_POS := {
	"t1":_FORS_W + _RS1, "t2":_FORS_W + _RS2, "h1":_FORS_W + _RS3, "h2":_FORS_W,
	"m1":_FORS_W - _RS1, "m2":_FORS_W - _RS2, "r1":_FORS_W - _RS3, "r2":_FORS_W,
}

const FORS_N_POS := {
	"t1":_FORS_N + _RS1, "t2":_FORS_N + _RS2, "h1":_FORS_N + _RS3, "h2":_FORS_N,
	"m1":_FORS_N - _RS1, "m2":_FORS_N - _RS2, "r1":_FORS_N - _RS3, "r2":_FORS_N,
}

const FORS_E_POS := {
	"t1":_FORS_E + _RS1, "t2":_FORS_E + _RS2, "h1":_FORS_E + _RS3, "h2":_FORS_E,
	"m1":_FORS_E - _RS1, "m2":_FORS_E - _RS2, "r1":_FORS_E - _RS3, "r2":_FORS_E,
}

# Over move to avoid first South bait
const FORS_SW_OVER_POS := {
	"t1":_FORS_SW_OVER + _RS1, "t2":_FORS_SW_OVER + _RS2, "h1":_FORS_SW_OVER + _RS3, "h2":_FORS_SW_OVER,
	"m1":_FORS_SW_OVER - _RS1, "m2":_FORS_SW_OVER - _RS2, "r1":_FORS_SW_OVER - _RS3, "r2":_FORS_SW_OVER,
}

const FORS_SW_POS := {
	"t1":_FORS_SW + _RS1, "t2":_FORS_SW + _RS2, "h1":_FORS_SW + _RS3, "h2":_FORS_SW,
	"m1":_FORS_SW - _RS1, "m2":_FORS_SW - _RS2, "r1":_FORS_SW - _RS3, "r2":_FORS_SW,
}

const FORS_NW_POS := {
	"t1":_FORS_NW + _RS1, "t2":_FORS_NW + _RS2, "h1":_FORS_NW + _RS3, "h2":_FORS_NW,
	"m1":_FORS_NW - _RS1, "m2":_FORS_NW - _RS2, "r1":_FORS_NW - _RS3, "r2":_FORS_NW,
}

const FORS_NE_POS := {
	"t1":_FORS_NE + _RS1, "t2":_FORS_NE + _RS2, "h1":_FORS_NE + _RS3, "h2":_FORS_NE,
	"m1":_FORS_NE - _RS1, "m2":_FORS_NE - _RS2, "r1":_FORS_NE - _RS3, "r2":_FORS_NE,
}

const FORS_SE_POS := {
	"t1":_FORS_SE + _RS1, "t2":_FORS_SE + _RS2, "h1":_FORS_SE + _RS3, "h2":_FORS_SE,
	"m1":_FORS_SE - _RS1, "m2":_FORS_SE - _RS2, "r1":_FORS_SE - _RS3, "r2":_FORS_SE,
}
