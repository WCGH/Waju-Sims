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
@onready var adjust_button: OptionButton = %AdjustButton
@onready var order_button: OptionButton = %OrderButton
@onready var odd_position_button: OptionButton = %OddPositionButton
@onready var even_position_button: OptionButton = %EvenPositionButton
@onready var spec_button: CheckButton = %SpecButton
@onready var player_bait_button: CheckButton = %PlayerBaitButton


#@onready var flex_button: CheckButton = %FlexButton


func _ready() -> void:
	strat_button.selected = DmuSavedVariables.save_data["settings"]["p2_fors_strat"]
	player_bait_button.button_pressed = DmuSavedVariables.save_data["settings"]["p2_fors_bait"]
	update_buttons()


func update_buttons():
	adjust_button.selected = DmuSavedVariables.save_data["settings"]["p2_fors_adjust_prio"]
	order_button.selected = DmuSavedVariables.save_data["settings"]["p2_fors_soak_order"]
	odd_position_button.selected = DmuSavedVariables.save_data["settings"]["p2_fors_odd_tower_pos"]
	even_position_button.selected = DmuSavedVariables.save_data["settings"]["p2_fors_even_tower_pos"]
	spec_button.button_pressed = DmuSavedVariables.save_data["settings"]["p2_fors_special_rule"]

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


func _on_strat_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_strat", index)
	
	# Get preset data from Encounter
	var strat_preset_dict = P2ForsSequence.STRAT_PRESET[index]
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_adjust_prio", strat_preset_dict["adjust_prio"])
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_soak_order", strat_preset_dict["soak_order"])
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_odd_tower_pos", strat_preset_dict["odd_position"])
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_even_tower_pos", strat_preset_dict["even_position"])
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_special_rule", strat_preset_dict["special_rule"])
	update_buttons()


func _on_adjust_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_adjust_prio", index)


func _on_order_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_soak_order", index)


func _on_odd_position_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_odd_tower_pos", index)


func _on_even_position_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_even_tower_pos", index)


func _on_spec_button_pressed() -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_special_rule", spec_button.button_pressed)


func _on_player_bait_button_pressed() -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p2_fors_bait", player_bait_button.button_pressed)
