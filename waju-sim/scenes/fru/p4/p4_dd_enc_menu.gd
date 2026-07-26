# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

@onready var encounter_config_button: TextureButton = %EncounterConfigButton
@onready var strat_margin_container: MarginContainer = %StratMarginContainer
@onready var mit_check_margin_container: MarginContainer = %MitCheckMarginContainer
# Buttons
@onready var lineup_button: OptionButton = %LineupButton
@onready var akh_morn_split_button: OptionButton = %AkhMornSplitButton
@onready var tankbuster_button: OptionButton = %TankbusterButton
@onready var force_tether_button: CheckButton = %ForceTetherButton
@onready var force_spirit_button: CheckButton = %ForceSpiritButton


func _ready() -> void:
	lineup_button.selected = FruSavedVariables.save_data["settings"]["p4_dd_strat"]
	akh_morn_split_button.selected = FruSavedVariables.save_data["settings"]["p4_dd_am_strat"]
	tankbuster_button.selected = FruSavedVariables.save_data["settings"]["p4_dd_dance_strat"]
	force_tether_button.button_pressed = FruGlobal.p4_dd_force_tether
	force_spirit_button.button_pressed = FruGlobal.p4_dd_force_spirit


func _on_encounter_config_button_pressed() -> void:
	toggle_encounter_menu()


func _on_close_button_pressed() -> void:
	hide_menu()


func close_mit_menu():
	mit_check_margin_container.hide()
	strat_margin_container.show()


func toggle_encounter_menu():
	close_mit_menu()
	self.visible = !self.visible


func hide_menu():
	close_mit_menu()
	self.hide()


# Strat Buttons
func _on_lineup_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p4_dd_strat", index)


func _on_akh_morn_split_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p4_dd_am_strat", index)


func _on_tankbuster_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p4_dd_dance_strat", index)


func _on_force_tether_button_pressed() -> void:
	FruGlobal.p4_dd_force_tether = force_tether_button.button_pressed


func _on_force_spirit_button_pressed() -> void:
	FruGlobal.p4_dd_force_spirit = force_spirit_button.button_pressed
