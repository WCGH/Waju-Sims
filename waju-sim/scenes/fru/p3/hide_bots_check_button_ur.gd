# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CheckButton

signal toggle_bots_visible


func _ready() -> void:
	button_pressed = FruGlobal.p3_ur_hide_bots


func _on_pressed() -> void:
	FruGlobal.p3_ur_hide_bots = button_pressed
	toggle_bots_visible.emit()
