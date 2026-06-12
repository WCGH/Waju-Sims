# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton

@onready var main_sequence = $"../.."


func _ready() -> void:
	if main_sequence is not Sequence:
		main_sequence = $"../../.."
		assert(main_sequence is Sequence)
	
	selected = SavedVariables.get_encounter_data("settings", "selected_seq")


func _on_item_selected(index : int) -> void:
	var current_scene = SavedVariables.get_encounter_data("settings", "selected_seq")
	GameEvents.emit_encounter_variable_saved("settings", "selected_seq", index)
	if index != current_scene:
		main_sequence.save_variables()
		get_tree().change_scene_to_file(Global.main_uid)
