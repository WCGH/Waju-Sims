# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends HBoxContainer

@onready var buttons_vbox: VBoxContainer = $".."
@onready var lineup_menu: MarginContainer = %LineupMenuContainer

var extra_node_count := 2  # Number of nodes in the container before the role nodes


func _on_up_button_pressed() -> void:
	var index := get_index() - extra_node_count
	if index == 0:
		return
	buttons_vbox.move_child(self, index + extra_node_count - 1)
	lineup_menu.save_lineup()
	# Swap key in array with previous one
	var temp : String = lineup_menu.lineup_keys[index - 1]
	lineup_menu.lineup_keys[index - 1] = lineup_menu.lineup_keys[index]
	lineup_menu.lineup_keys[index] = temp
	lineup_menu.save_lineup()


func _on_down_button_pressed() -> void:
	var index := get_index() - 2
	if index == 7:
		return
	buttons_vbox.move_child(self, index + extra_node_count + 1)
	lineup_menu.save_lineup()
	# Swap key in array with next one
	var temp : String = lineup_menu.lineup_keys[index + 1]
	lineup_menu.lineup_keys[index + 1] = lineup_menu.lineup_keys[index]
	lineup_menu.lineup_keys[index] = temp
	lineup_menu.save_lineup()
