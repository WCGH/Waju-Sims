# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

signal variable_saved(section: String, key: String, value: Variant)
signal variable_removed(section: String, key: String)
signal fru_variable_saved(section: String, key: String, value: Variant)
signal dsr_variable_saved(section: String, key: String, value: Variant)
signal dmu_variable_saved(section: String, key: String, value: Variant)
signal party_ready()
signal spectate_mode_changed()
signal toggle_move_ui(move_ui: bool)
signal ui_ready
signal toggle_focus(role_key: String)


func emit_variable_saved(section: String, key: String, value: Variant) -> void:
	variable_saved.emit(section, key, value)


func emit_encounter_variable_saved(section: String, key: String, value: Variant) -> void:
	match Global.encounter:
		Global.Encounter.FRU:
			fru_variable_saved.emit(section, key, value)
		Global.Encounter.DSR:
			dsr_variable_saved.emit(section, key, value)
		Global.Encounter.DMU:
			dmu_variable_saved.emit(section, key, value)


func emit_variable_removed(section: String, key: String) -> void:
	variable_removed.emit(section, key)


func emit_party_ready() -> void:
	party_ready.emit()


func emit_spectate_mode_changed() -> void:
	spectate_mode_changed.emit()


func emit_toggle_move_ui(move_ui: bool) -> void:
	Global.is_moving_ui = move_ui
	toggle_move_ui.emit(move_ui)


# Signals that the window resolution has been set and is ready to set UI elements.
func emit_ui_ready() -> void:
	ui_ready.emit()


func emit_toggle_focus(role_key: String):
	toggle_focus.emit(role_key)
