# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton

func _ready() -> void:
	selected = SavedVariables.save_data["settings"]["player_role"]


func _on_item_selected(index : int) -> void:
	var session := get_node("/root/DmuSession")
	if Global.encounter == Global.Encounter.DMU and session.is_multiplayer_session():
		return
	GameEvents.emit_variable_saved("settings", "player_role", index)
