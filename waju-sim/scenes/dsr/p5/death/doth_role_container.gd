# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends HBoxContainer

@onready var buttons_vbox: VBoxContainer = $".."
@onready var doth_order_margin_container: MarginContainer = %DothOrderMarginContainer


func _on_up_button_pressed() -> void:
	var index: int = get_index() - doth_order_margin_container.HEADER_NODE_COUNT
	if index == 0:
		return
	buttons_vbox.move_child(self, index + doth_order_margin_container.HEADER_NODE_COUNT - 1)
	doth_order_margin_container.save_lineup()
	# Swap key in array with previous one
	var temp : String = doth_order_margin_container.party_keys[index - 1]
	doth_order_margin_container.party_keys[index - 1] = doth_order_margin_container.party_keys[index]
	doth_order_margin_container.party_keys[index] = temp
	doth_order_margin_container.order_containers()
	doth_order_margin_container.save_lineup()


func _on_down_button_pressed() -> void:
	var index: int = get_index() - doth_order_margin_container.HEADER_NODE_COUNT
	if index == 7:
		return
	buttons_vbox.move_child(self, index + doth_order_margin_container.HEADER_NODE_COUNT + 1)
	doth_order_margin_container.save_lineup()
	# Swap key in array with next one
	var temp : String = doth_order_margin_container.party_keys[index + 1]
	doth_order_margin_container.party_keys[index + 1] = doth_order_margin_container.party_keys[index]
	doth_order_margin_container.party_keys[index] = temp
	doth_order_margin_container.order_containers()
	doth_order_margin_container.save_lineup()
