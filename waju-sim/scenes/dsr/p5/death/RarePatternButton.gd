# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CheckButton


func _ready() -> void:
	set_pressed(Global.rare_death_pattern)


func _on_pressed() -> void:
	Global.rare_death_pattern = !Global.rare_death_pattern
