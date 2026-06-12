# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

@onready var encounter_config_button: TextureButton = %EncounterConfigButton
@onready var strat_margin_container: MarginContainer = %StratMarginContainer
@onready var mit_check_margin_container: MarginContainer = %MitCheckMarginContainer
@onready var wb_1_button: OptionButton = %WB1Button
@onready var vow_button: OptionButton = %VowButton
@onready var wroth_markers_button: OptionButton = %WrothMarkersButton
@onready var wroth_spread_button: OptionButton = %WrothSpreadButton
@onready var wb_2_button: OptionButton = %WB2Button
@onready var sub_sequence_select_button: OptionButton = %SubSequenceSelectButton


func _ready() -> void:
	wb_1_button.selected = DsrSavedVariables.get_data("p6", "wb_1")
	vow_button.selected = DsrSavedVariables.get_data("p6", "first_vow")
	wroth_markers_button.selected = DsrSavedVariables.get_data("p6", "t_markers")
	wroth_spread_button.selected = DsrSavedVariables.get_data("p6", "wroth")
	wb_2_button.selected = DsrSavedVariables.get_data("p6", "wb_2")
	sub_sequence_select_button.selected = DsrGlobal.p6_selected_seq


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


func _on_sub_sequence_select_button_item_selected(index: int) -> void:
	DsrGlobal.p6_selected_seq = index
	get_tree().reload_current_scene()


func _on_wb_1_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("p6", "wb_1", index)


func _on_vow_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("p6", "first_vow", index)


func _on_wroth_markers_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("p6", "t_markers", index)


func _on_wroth_spread_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("p6", "wroth", index)


func _on_wb_2_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("p6", "wb_2", index)
