# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for BoA/Limit Cut sequence.

extends Node

class_name BoAPos


# 'Random' spread values so bots aren't stacked.
const RS1 := Vector2(0.3, 0.2)
const RS2 := Vector2(0.15, -0.28)
const RS3 := Vector2(-0.2, 0.1)



## sg3k

# Not rotated
const DECISIVE_POS_SG := {
	"t1": Vector2(-7.7, 0.0), "h1": Vector2(-9.8, -5.7),
	"m1": Vector2(-16.0, 5.0), "m2": Vector2(-11.3, 3.4),
	"t2": Vector2(8.0, 0.0), "h2": Vector2(9.0, -5.7),
	"r1": Vector2(11.3, 3.4), "r2": Vector2(16.0, 5.0),
}

# Pull bosses mid
const POST_DECISIVE_TANK_POS_SG := {
	"t1": Vector2(10, 0.0), "t2": Vector2(-10.0, 0.0),
}

# Base positions are for Fire NW, Wind NE, Water SE, which will get rotated in code.
# Move Exdeath opposite of short debuff. Base position assumes short fire.
const PRE_FIRE_TANK_POS_1_SG := {
	"t1": Vector2(11.7, -27.3), "t2": Vector2(25.5, 37.5),
}
# Second Tank adjustment to get Exdeath on wall.
const PRE_FIRE_TANK_POS_2_SG := {
	"t2": Vector2(37.5, 25.5),
}

# Short/Long Debuffs specified here since Wind soakers keep same positions for second soak.
const SHORT_FIRE_POS_SG := {
	"short_dps": Vector2(-11.6, -11.6), "long_dps": Vector2(-2.1, -0.5), "short_sup": Vector2(-32, -32), "long_sup": Vector2(-0.5, -2.1),
	"wind_sup_near": Vector2(13.8, -24.9), "wind_sup_far": Vector2(30.1, -16.4), "wind_dps_near": Vector2(8.3, -32.1), "wind_dps_far": Vector2(38.1, -14.0)
}
const SHORT_WATER_POS_SG := {
	"short_dps": Vector2(11.6, 11.6), "long_dps": Vector2(6.8, 7.8), "short_sup": Vector2(32, 32), "long_sup": Vector2(7.8, 6.8),
	"wind_sup_near": Vector2(24.9, -13.8), "wind_sup_far": Vector2(16.4, -30.1), "wind_dps_near": Vector2(32.1, -8.3), "wind_dps_far": Vector2(14.0, -38.1)
}
const LONG_FIRE_POS_SG := {
	"short_dps": Vector2(-2.1, -0.5), "long_dps": Vector2(-11.6, -11.6), "short_sup": Vector2(-0.5, -2.1), "long_sup": Vector2(-32, -32),
	"wind_sup_near": Vector2(24.9, -13.8), "wind_sup_far": Vector2(16.4, -30.1), "wind_dps_near": Vector2(32.1, -8.3), "wind_dps_far": Vector2(14.0, -38.1)
}
const LONG_WATER_POS_SG := {
	"short_dps": Vector2(6.8, 7.8), "long_dps": Vector2(11.6, 11.6), "short_sup": Vector2(7.8, 6.8), "long_sup": Vector2(32, 32),
	"wind_sup_near": Vector2(13.8, -24.9), "wind_sup_far": Vector2(30.1, -16.4), "wind_dps_near": Vector2(8.3, -32.1), "wind_dps_far": Vector2(38.1, -14.0)
}

# Latlong base positions. Fire/Water along SE, Wind along NE.
const LATLONG_SE_POS_SG := {
	"short_dps": Vector2(7, 7), "long_dps": Vector2(11.6, 11.6), "short_sup": Vector2(8, 8), "long_sup": Vector2(32, 32),
	
}
const LATLONG_NE_POS_SG := {
	"wind_sup_near": Vector2(26, -26), "wind_sup_far": Vector2(25, -25), "wind_dps_near": Vector2(18, -18), "wind_dps_far": Vector2(19, -19)
}

# Umbra bait. Phys ranged (R1) baits jump.
const UMBRA_BAIT_POS_SG := {
	"t1": Vector2(-30.7, 30.5), "t2": Vector2(-30.5, 30), "h1": Vector2(-13.7, 18), "h2": Vector2(-18, 13.7),
	"m1": Vector2(-15, 18.5), "m2": Vector2(-18.5, 15), "r1": Vector2(32.0, -32.0), "r2": Vector2(-16.0, 14.0),
}

# Called after Umbra/Vaccum cast starts
const UMBRA_CAST_POS_SG := {
	"t1": Vector2(-12.2, 11.1) + RS1, "t2": Vector2(-12.2, 11.1) + RS2, "h1": Vector2(-12.2, 11.1) + RS3, "h2": Vector2(-12.2, 11.1),
	"m1": Vector2(-11.1, 12.2) + RS1, "m2": Vector2(-11.1, 12.2) + RS2, "r1": Vector2(-11.1, 12.2) + RS3, "r2": Vector2(-11.1, 12.2),
}

const WINDS_3_BAIT_POS := {
	"t1": Vector2(22, -33) + RS1, "t2": Vector2(13, -23) + RS2, "h1": Vector2(17, -40) + RS3, "h2": Vector2(7, -22),
	"m1": Vector2(33, -22) + RS1, "m2": Vector2(23, -13) + RS2, "r1": Vector2(40, -17) + RS3, "r2": Vector2(22, -7),
}
