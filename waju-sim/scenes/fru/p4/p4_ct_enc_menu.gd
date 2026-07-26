# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

@onready var encounter_config_button: TextureButton = %EncounterConfigButton
@onready var strat_margin_container: MarginContainer = %StratMarginContainer
@onready var mit_check_margin_container: MarginContainer = %MitCheckMarginContainer
# Buttons
@onready var strat_button: OptionButton = %StratButton
@onready var akh_morn_split_button: OptionButton = %AkhMornSplitButton
@onready var debuff_button: OptionButton = %DebuffButton
@onready var aero_plant_button: CheckButton = %AeroPlantButton
@onready var force_spirit_button: CheckButton = %ForceSpiritButton


func _ready() -> void:
	strat_button.selected = FruSavedVariables.save_data["settings"]["p4_ct_strat"]
	akh_morn_split_button.selected = FruSavedVariables.save_data["settings"]["p4_ct_am_strat"]
	debuff_button.selected = FruGlobal.p4_ct_selected_debuff
	aero_plant_button.button_pressed = FruSavedVariables.save_data["settings"]["p4_ct_aero_plant"]
	force_spirit_button.button_pressed = FruGlobal.p4_ct_force_spirit


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
func _on_strat_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p4_ct_strat", index)


func _on_akh_morn_split_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p4_ct_am_strat", index)


func _on_debuff_button_item_selected(index: int) -> void:
	FruGlobal.p4_ct_selected_debuff = index


func _on_aero_plant_button_pressed() -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p4_ct_aero_plant", aero_plant_button.button_pressed)


func _on_force_spirit_button_pressed() -> void:
	FruGlobal.p4_ct_force_spirit = force_spirit_button.button_pressed
