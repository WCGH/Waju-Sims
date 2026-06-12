# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Used for storing bot positions for Crystallize Time sequence

extends Node

class_name ForsPositions


# 'Random' spread values so bots aren't stacked
const RS1 := Vector2(0.3, 0.2)
const RS2 := Vector2(0.15, -0.28)
const RS3 := Vector2(-0.2, 0.1)

# Tower constants
const _TWR_DIST := 18.25      # Distance to center of tower
const _TWR_EDGE := 7.5        # Distance from center of tower to near edge, 25.75 combined
const _TWR_OUT := 10.2         # Distance from center of tower to just outside
const _CONE_OFFSET := 2.1

# Inner bait constants
const _BAIT_FAR_XY := 10.0  # Diagonal coords for far bait (G1 Support)
const _BAIT_SIDE_X := 13.0  # G1/G2 DPS positions (these need to be precise)
const _BAIT_SIDE_Y := 5.4

# Lineup, party keys
const _LN_FAR_X := 17.6
const _LN_NEAR_X := 10.0
const _LN_Y := 1.8

const _HB_EDGE := 14.4            # Hitbox edge, used for T1 left stack.
const _NEAR_EDGE_OUT := 8.1
const _NEAR_EDGE_IN := 10.4
const _FAR_BAIT := 32.0           # For non-tower healer, baiting away from edge.
const _TWR_EDGE_RTD_X := 5.5      # (0, 25.75) rotated 45/135 deg. Used for UA T1 Right soakers.
const _TWR_OUT_EDGE_RTD_Y := 23.7
const _TWR_IN_EDGE_RTD_Y := 12.77



## Rin Positions

const LINEUP_POS_RIN := {
	"h1": Vector2(-_LN_FAR_X + 2.5, -_LN_Y - 2.0), "h2": Vector2(-_LN_FAR_X + 2.5, _LN_Y + 2.0),
	"t1": Vector2(-_LN_NEAR_X - 2.5, -_LN_Y - 2.0), "t2": Vector2(-_LN_NEAR_X - 2.5, _LN_Y + 2.0),
	"m1": Vector2(_LN_NEAR_X + 2.5, -_LN_Y - 2.0), "m2": Vector2(_LN_NEAR_X + 2.5, _LN_Y + 2.0),
	"r1": Vector2(_LN_FAR_X  - 2.5, -_LN_Y - 2.0), "r2": Vector2(_LN_FAR_X - 2.5, _LN_Y + 2.0),
}

# Variant 1 (Odd Towers)
# V1 In Towers (2 stacks, 1 cone, 1 spread) Group A: 1/3, Group B: 5/7
const V1_IN_POS_RIN := {
	"stack_left": Vector2(_HB_EDGE, 0), "stack_right": Vector2(-_TWR_EDGE_RTD_X, -_TWR_IN_EDGE_RTD_Y),
	"cone_left": Vector2(_TWR_DIST + _TWR_EDGE, 0), "spread_left": Vector2(_TWR_EDGE_RTD_X, -_TWR_OUT_EDGE_RTD_Y)
}
# V1 Stacks (2 cones, 2 spreads) Group A: 5/7, Group B: 1/3
const V1_STACK_POS_RIN := {
	"h": Vector2(_FAR_BAIT, 0), "t": Vector2(_NEAR_EDGE_OUT, 0),
	"r": Vector2(-0.8, -_NEAR_EDGE_OUT), "m": Vector2(0.5, -_NEAR_EDGE_OUT)
}

# New Rin (Even Towers) Inner Hitbox, Bait on markers
# V2 In Towers (2 cones, 2 spreads) Group A: 2/8, Group B: 4/6
const V2_IN_POS_RIN := {
	"cone_left": Vector2(11.5, 4.3), "cone_right": Vector2(-4.3, -11.5),
	"spread_left": Vector2(25, -4.3), "spread_right": Vector2(4.3, -25)
}
# V2 Baits (static) Group A: 4/6, Group B: 2/8
const V2_BAIT_POS_RIN := {
	"h": Vector2(16.4, 16.4), "r": Vector2(-16.4, -16.4), 
	"t": Vector2(-2.5, 14.2), "m": Vector2(-14.2, 2.5)
}








## Old Rin Even Towers (Boss relative, 90 deg)

# Variant 2 (Even Towers)
# V2 In Towers (2 cones, 2 spreads) Group A: 2/8, Group B: 4/6
const V2_IN_POS_BOSS := {
	"cone_left": Vector2(_NEAR_EDGE_IN, 0), "cone_right": Vector2(0, -_NEAR_EDGE_IN),
	"spread_left": Vector2(_TWR_DIST + _TWR_EDGE, 0), "spread_right": Vector2(0, -_TWR_DIST - _TWR_EDGE)
}
# V2 Baits (static) Group A: 4/6, Group B: 2/8
const V2_BAIT_POS_BOSS := {
	"h": Vector2(_TWR_DIST, _TWR_OUT + 1.0), "r": Vector2(-_TWR_OUT - 1.0, -_TWR_DIST), 
	"t": Vector2(-2.5, 14.2), "m": Vector2(-14.2, 2.5)
}



## EU/Meow
# V2 is same as Rin

const LINEUP_POS_EU := {
	"h1": Vector2(-_LN_NEAR_X - 3.2, -_LN_Y - 5.0), "h2": Vector2(-_LN_NEAR_X - 3.2, _LN_Y + 5.0),
	"t1": Vector2(-_LN_NEAR_X - 3.2, -_LN_Y - 2.0), "t2": Vector2(-_LN_NEAR_X - 3.2, _LN_Y + 2.0),
	"m1": Vector2(_LN_NEAR_X + 3.2, -_LN_Y - 2.0), "m2": Vector2(_LN_NEAR_X + 3.2, _LN_Y + 2.0),
	"r1": Vector2(_LN_NEAR_X + 3.2, -_LN_Y - 5.0), "r2": Vector2(_LN_NEAR_X + 3.2, _LN_Y + 5.0),
}

# EU Variant 1 (Odd Towers)
# V1 In Towers (2 stacks, 1 cone, 1 spread) Group A: 1/3, Group B: 5/7
const V1_IN_POS_EU := {
	"stack_left": Vector2(18.3, 1.3), "stack_right": Vector2(7.9, -19.0),
	"cone_left": Vector2(18, -8.2), "spread_left": Vector2(-7.7, -18.6)
}
# V1 Stacks (2 cones, 2 spreads) Group A: 5/7, Group B: 1/3
const V1_STACK_POS_EU := {
	"h": Vector2(23.2, -11.9), "t": Vector2(9, -4.6),
	"r": Vector2(10.9, -20.7), "m": Vector2(10, -15.4)
}
# EU Variant 2 (Even Towers) Inner Hitbox Align
# V2 In Towers (2 cones, 2 spreads) Group A: 2/8, Group B: 4/6
const V2_IN_POS_EU := {
	"cone_left": Vector2(11.5, 4.3), "cone_right": Vector2(-4.3, -11.5),
	"spread_left": Vector2(25, -4.3), "spread_right": Vector2(4.3, -25)
}
# V2 Baits (static) Group A: 4/6, Group B: 2/8
const V2_BAIT_POS_EU := {
	"h": Vector2(24.3, 8.3), "r": Vector2(-8.3, -24.3), 
	"t": Vector2(-2.5, 14.2), "m": Vector2(-14.2, 2.5)
}


## South
# Variant 1 (Odd Towers)
# V1 In Towers (2 stacks, 1 cone, 1 spread) Group A: 1/3, Group B: 5/7
const V1_IN_POS_BOSS_ALIGN := {
	"stack_left": Vector2(_HB_EDGE, 0), "stack_right": Vector2(0, -_NEAR_EDGE_IN),
	"cone_left": Vector2(_TWR_DIST + _TWR_EDGE, 0), "spread_left": Vector2(0, -_TWR_DIST - _TWR_EDGE)
}
# V1 Stacks (2 cones, 2 spreads) Group A: 5/7, Group B: 1/3
const V1_STACK_POS_BOSS_ALIGN := {
	"h": Vector2(_FAR_BAIT, 0), "t": Vector2(_NEAR_EDGE_OUT, 2.0),
	"r": Vector2(-0.8, -_NEAR_EDGE_OUT), "m": Vector2(0.5, -_NEAR_EDGE_OUT)
}


# T2 Outter Hitbox Align
# V2 In Towers (2 cones, 2 spreads) Group A: 2/8, Group B: 4/6
const V2_IN_POS_OUTTER := {
	"cone_left": Vector2(12.5, 5.4), "cone_right": Vector2(-5.4, -12.6),
	"spread_left": Vector2(22.8, -6.6), "spread_right": Vector2(6.6, -22.8)
}
# V2 Baits (static) Group A: 4/6, Group B: 2/8
const V2_BAIT_POS_OUTTER := {
	"h": Vector2(25.4, 7.2), "r": Vector2(-7.2, -25.4), 
	"t": Vector2(-2.5, 14.2), "m": Vector2(-14.2, 2.5)
}



## Modified ABBA (N/S relative).

const LINEUP_POS_ABBA := {
	"h1": Vector2(-_LN_FAR_X + 2.5, -_LN_Y - 2.0), "r1": Vector2(-_LN_FAR_X + 2.5, _LN_Y + 2.0),
	"t1": Vector2(-_LN_NEAR_X - 2.5, -_LN_Y - 2.0), "m1": Vector2(-_LN_NEAR_X - 2.5, _LN_Y + 2.0),
	"t2": Vector2(_LN_NEAR_X + 2.5, -_LN_Y - 2.0), "m2": Vector2(_LN_NEAR_X + 2.5, _LN_Y + 2.0),
	"h2": Vector2(_LN_FAR_X  - 2.5, -_LN_Y - 2.0), "r2": Vector2(_LN_FAR_X - 2.5, _LN_Y + 2.0),
}

# Variant 1 (Odd Towers) - N/S
# V1 In Towers (2 stacks, 1 cone, 1 spread) Group A: 1/3, Group B: 5/7
const V1_IN_POS_ABBA := {
	"stack_left": Vector2(15, 3.4), "stack_right": Vector2(-5.2, -12.4),
	"cone_left": Vector2(24, -4.8), "spread_left": Vector2(5.5, -24.2)
}
# V1 Stacks (2 cones, 2 spreads) Group A: 5/7, Group B: 1/3
const V1_STACK_POS_ABBA := {
	"h": Vector2(27.2, -7.5), "t": Vector2(8.8, 3.7),
	"r": Vector2(-4.5, -9.2), "m": Vector2(-1.6, -8.5)
}

# Variant 2 (Even Towers)
# V2 In Towers (2 cones, 2 spreads) Group A: 2/8, Group B: 4/6
const V2_IN_POS_ABBA := {
	"cone_left": Vector2(12.7, 5.6), "cone_right": Vector2(-5.6, -12.7),
	"spread_left": Vector2(23.8, -5.4), "spread_right": Vector2(5.4, -23.8)
}
# V2 Baits (static) Group A: 4/6, Group B: 2/8
const V2_BAIT_POS_ABBA := {
	"h": Vector2(25.3, 7.8), "r": Vector2(-7.8, -25.3), 
	"t": Vector2(-2.5, 14.2), "m": Vector2(-14.2, 2.5)
}



## Common Positioning

const FUTURE_BAIT_POS := {
	"h1": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY) + RS1, "h2": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY) - RS1,
	"t1": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY) + RS2, "t2": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY) - RS2,
	"m1": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY) + RS3, "m2": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY) - RS3,
	"r1": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY), "r2": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY) + RS1 - RS3,
}
const PAST_BAIT_POS := {
	"h1": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY) + RS1, "h2": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY) - RS1,
	"t1": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY) + RS2, "t2": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY) - RS2,
	"m1": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY) + RS3, "m2": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY) - RS3,
	"r1": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY), "r2": Vector2(_BAIT_FAR_XY, -_BAIT_FAR_XY) + RS1 - RS3,
}
const BAIT_MIDDLE_POS := {
	"h1": Vector2.ZERO, "h2": Vector2.ZERO,
	"t1": Vector2.ZERO, "t2": Vector2.ZERO,
	"m1": Vector2.ZERO, "m2": Vector2.ZERO,
	"r1": Vector2.ZERO, "r2": Vector2.ZERO,
}







## Old Double Cone positions (Deprecated)

#const LINEUP_POS_KB := {
	#"h1": Vector2(-_LN_FAR_X, -_LN_Y), "h2": Vector2(-_LN_FAR_X, _LN_Y),
	#"t1": Vector2(-_LN_NEAR_X, -_LN_Y), "t2": Vector2(-_LN_NEAR_X, _LN_Y),
	#"m1": Vector2(_LN_NEAR_X, -_LN_Y), "m2": Vector2(_LN_NEAR_X, _LN_Y),
	#"r1": Vector2(_LN_FAR_X, -_LN_Y), "r2": Vector2(_LN_FAR_X, _LN_Y),
#}


# Variant 1 (Odd Towers)
# V1 In Towers (2 stacks, 1 cone, 1 spread) Group A: 1/5, Group B: 3/7
#const V1_IN_POS_KB := {
	#"stack_left": Vector2(_TWR_DIST, _TWR_EDGE), "stack_right": Vector2(-_TWR_EDGE, -_TWR_DIST),
	#"cone_left": Vector2(_TWR_DIST + _TWR_EDGE, 0), "spread_left": Vector2(_TWR_EDGE, -_TWR_DIST)
#}
## V1 Stacks (2 cones, 2 spreads) Group A: 3/7, Group B: 1/5
#const V1_STACK_POS_KB := {
	#"cone_left": Vector2(_TWR_DIST, _TWR_OUT), "cone_right": Vector2(_TWR_DIST + _TWR_OUT + 2.0, 0),
	#"spread_left": Vector2(-9.4, -14.2), "spread_right": Vector2(-9.3, -14.6)
#}
## Variant 2 (Even Towers)
## V2 In Towers (2 cones, 2 spreads) Group A: 4/8, Group B: 2/6
#const V2_IN_POS_KB := {
	#"cone_left": Vector2(_TWR_DIST + _TWR_EDGE - 0.4, _CONE_OFFSET), "cone_right": Vector2(_TWR_DIST + _TWR_EDGE, -_CONE_OFFSET),
	#"spread_left": Vector2(_TWR_EDGE, -_TWR_DIST + 1.3), "spread_right": Vector2(-_TWR_EDGE, -_TWR_DIST)
#}
## V2 Baits (static) Group A: 2/6, Group B: 4/8
#const V2_BAIT_POS_KB := {
	#"g1_dps": Vector2(_BAIT_SIDE_Y, _BAIT_SIDE_X), "g2_dps": Vector2(-_BAIT_SIDE_X, -_BAIT_SIDE_Y), 
	#"g1_sup": Vector2(-_BAIT_FAR_XY, _BAIT_FAR_XY), "g2_sup": Vector2(0, 0)
#}
