# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton


func _ready() -> void:
	#var saved_index: int = SavedVariables.save_data["p5"]["dooms"]
	#if saved_index == SavedVariables.dooms.DEFAULT:
		#saved_index = SavedVariables.get_default("p5", "dooms")
	pass
	#selected = SavedVariables.get_data("p7", "am2")


func _on_item_selected(_index : int) -> void:
	pass
	#GameEvents.emit_variable_saved("p7", "am2", index)
