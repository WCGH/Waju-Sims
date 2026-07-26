# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name P3S1_Positions_East

static var positions_db := {
	# Spawn positions
	"spawn_pos": {
		"lc1": {
			"up": Vector2(0, 5),
			"circle": Vector2(0, -5),
			"down": Vector2(-5, 0)
		},
		"lc2": {
			"up": Vector2(5, 0),
			"down": Vector2(5, 5)
		},
		"lc3": {
			"up": Vector2(5, -5),
			"circle": Vector2(-5, 5),
			"down": Vector2(-5, -5)
		}
	},
	# Initial spread positions
	"pre_spread": {
		"lc1": {
			"up": Vector2(0, 7),
			"circle": Vector2(0, -8),
			"down": Vector2(5, 0)
		},
		"lc2": {
			"up": Vector2(-5, 0),
			"down": Vector2(10, -2)
		},
		"lc3": {
			"up": Vector2(-10, -2),
			"circle": Vector2(-2, -10),
			"down": Vector2(3, -11)
		}
	},
	# LC stage positions
	"lc_setup": {
		"lc1": {
			"up": Vector2(15, 0),
			"circle": Vector2(0, -15),
			"down": Vector2(-15, 0)
		},
		"lc2": {
			"up": Vector2(5, 10),
			"down": Vector2(-5, 10)
		},
		"lc3": {
			"up": Vector2(9, 0),
			"circle": Vector2(0, -9),
			"down": Vector2(-9, 0)
		}
	},
	# Tower 1 Drop Positions
	"t1_p1": {
		"lc1": {
			"up": Vector2(15, 0),
			"circle": Vector2(0, -15),
			"down": Vector2(-15, 0)
		},
		"lc2": {
			"up": Vector2(1, 15.5),
			"down": Vector2(-1, 15.5)
		},
		"lc3": {
			"up": Vector2(1, 15),
			"circle": Vector2(0, 14.2),
			"down": Vector2(-1, 15)
		}
	},
	# Tower Soak Positions (Lash first)
	"t1_p2_in": {
		"lc1": {
			"up": Vector2(0, 13),
			"circle": Vector2(0, 13),
			"down": Vector2(0, 13)
		},
		"lc2": {
			"up": Vector2(2, 13),
			"down": Vector2(-2, 13)
		},
		"lc3": {
			"up": Vector2(13, 0),
			"circle": Vector2(0, -13),
			"down": Vector2(-13, 0)
		}
	},
	# Tower Soak Positions (Gnash first)
	"t1_p2_out": {
		"lc1": {
			"up": Vector2(0, 17),
			"circle": Vector2(0, 17),
			"down": Vector2(0, 17)
		},
		"lc2": {
			"up": Vector2(2, 17),
			"down": Vector2(-2, 17)
		},
		"lc3": {
			"up": Vector2(17, 0),
			"circle": Vector2(0, -17),
			"down": Vector2(-17, 0)
		}
	},
	# Tower Soak Positions (Lash second)
	"t1_p3_in": {
		"lc1": {
			"up": Vector2(0, 13),
			"circle": Vector2(0, 13),
			"down": Vector2(0, 13)
		},
		"lc2": {
			"up": Vector2(2, 13),
			"down": Vector2(-2, 13)
		},
		"lc3": {
			"up": Vector2(13, 0),
			"circle": Vector2(0, -13),
			"down": Vector2(-13, 0)
		}
	},
	# Tower Soak Positions (Gnash second)
	"t1_p3_out": {
		"lc1": {
			"up": Vector2(0, 17),
			"circle": Vector2(0, 17),
			"down": Vector2(0, 17)
		},
		"lc2": {
			"up": Vector2(13, 18.5),
			"down": Vector2(-13, 18.5)
		},
		"lc3": {
			"up": Vector2(17, 0),
			"circle": Vector2(0, -17),
			"down": Vector2(-17, 0)
		}
	},
	# Tower 2 Drop and Clone Line baits
	"t2_p1": {
		"lc1": {
			"up": Vector2(0, 15),
			"circle": Vector2(0, 15),
			"down": Vector2(0, 15)
		},
		"lc2": {
			"up": Vector2(13, 18.5),
			"down": Vector2(-13, 18.5)
		},
		"lc3": {
			"up": Vector2(20, 0),
			"circle": Vector2(0, -20),
			"down": Vector2(-20, 0)
		}
	},
	# Tower 2 Soak and Clone Line dodge
	"t2_p2": {
		"lc1": {
			"up": Vector2(20, 23),
			"circle": Vector2(0, 15),
			"down": Vector2(-20, 23)
		},
		"lc2": {
			"up": Vector2(0, 15),
			"down": Vector2(0, 15)
		},
		"lc3": {
			"up": Vector2(10, 0),
			"circle": Vector2(0, -10),
			"down": Vector2(-10, 0)
		}
	},
	# Tower 3 Drop Positions
	"t3_p1": {
		"lc1": {
			"up": Vector2(1, 15),
			"circle": Vector2(0, 14.2),
			"down": Vector2(-1, 15)
		},
		"lc2": {
			"up": Vector2(1, 15.5),
			"down": Vector2(-1, 15.5)
		},
		"lc3": {
			"up": Vector2(15, 0),
			"circle": Vector2(0, -15),
			"down": Vector2(-15, 0)
		}
	},
	# Tower 3 Soak Positions (In first)
	"t3_p2_in": {
		"lc1": {
			"up": Vector2(1, 13),
			"circle": Vector2(0, -13),
			"down": Vector2(-1, 13)
		},
		"lc2": {
			"up": Vector2(13, 0),
			"down": Vector2(-13, 0)
		},
		"lc3": {
			"up": Vector2(5, 12),
			"circle": Vector2(-5, 12),
			"down": Vector2(-5, 12)
		}
	},
	# Tower 3 Soak Positions (Out first)
	"t3_p2_out": {
		"lc1": {
			"up": Vector2(1, 18),
			"circle": Vector2(0, -18),
			"down": Vector2(-1, 18)
		},
		"lc2": {
			"up": Vector2(18, 0),
			"down": Vector2(-18, 0)
		},
		"lc3": {
			"up": Vector2(7, 18),
			"circle": Vector2(-7, 18),
			"down": Vector2(-7, 18)
		}
	},
	"t3_p3": {
		"lc1": {
			"up": Vector2(7, 12.5),
			"circle": Vector2(0, -12),
			"down": Vector2(6.5, 12.5)
		},
		"lc2": {
			"up": Vector2(12, 0),
			"down": Vector2(-12, 0)
		},
		"lc3": {
			"up": Vector2(7, 12),
			"circle": Vector2(-7.5, 12),
			"down": Vector2(-7.5, 12)
		}
	},
	# Standalone V3 positions (inverted for Easthog)
	"west": Vector3(-50, 0, 0),
	"t2_west": Vector3(-50, 0, 18.5)
}
