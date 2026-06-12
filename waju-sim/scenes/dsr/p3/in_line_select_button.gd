# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton

@onready var arrow_select_button: OptionButton = %ArrowSelectButton


func _ready() -> void:
	selected = SavedVariables.get_data("p3", "in_line")


func _on_item_selected(index : int) -> void:
	# If LC2 disable Circle arrow option.
	if index == SavedVariables.in_line.TWO:
		arrow_select_button.set("popup/item_2/disabled", true)
		# If Circle is selected, change it to default (random).
		if SavedVariables.get_data("p3", "arrow") == SavedVariables.arrow.CIRCLE:
			GameEvents.emit_variable_saved("p3", "arrow", SavedVariables.arrow.RANDOM)
			arrow_select_button.selected = SavedVariables.arrow.RANDOM
	else:
		arrow_select_button.set("popup/item_2/disabled", false)
	GameEvents.emit_variable_saved("p3", "in_line", index)
