# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton


func _ready() -> void:
	var in_line: int = SavedVariables.get_data("p3", "in_line")
	var arrow: int = SavedVariables.get_data("p3", "arrow")
	# Normal behavior.
	if in_line != SavedVariables.in_line.TWO:
		selected = arrow
		self.set("popup/item_2/disabled", false)
	# Handle invalid LC2 + Circle (change to random)
	elif arrow == SavedVariables.arrow.CIRCLE:
		selected = SavedVariables.arrow.RANDOM
		GameEvents.emit_variable_saved("p3", "arrow", SavedVariables.arrow.RANDOM)
		self.set("popup/item_2/disabled", true)
	# Handle valid LC2
	else:
		selected = arrow
		self.set("popup/item_2/disabled", true)

func _on_item_selected(index : int) -> void:
	GameEvents.emit_variable_saved("p3", "arrow", index)
