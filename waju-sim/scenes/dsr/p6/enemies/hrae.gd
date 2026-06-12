# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends P6Boss


func toggle_right_wing() -> void:
	%WingsRight.visible = !%WingsRight.visible


func toggle_left_wing() -> void:
	%WingsLeft.visible = !%WingsLeft.visible
