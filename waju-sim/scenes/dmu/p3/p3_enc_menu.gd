# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.


extends CanvasLayer

signal toggle_bots_visible()

@onready var encounter_config_button: TextureButton = %EncounterConfigButton
@onready var strat_margin_container: MarginContainer = %StratMarginContainer
@onready var mit_check_margin_container: MarginContainer = %MitCheckMarginContainer
# Buttons
@onready var strat_button: OptionButton = %StratButton
@onready var starting_button: OptionButton = %StartingButton
@onready var hide_bots_check_button: CheckButton = %HideBotsCheckButton


#@onready var flex_button: CheckButton = %FlexButton


func _ready() -> void:
	strat_button.selected = DmuSavedVariables.save_data["settings"]["p3_boa_strat"]
	starting_button.selected = DmuSavedVariables.save_data["settings"]["p3_boa_start_point"]
	hide_bots_check_button.button_pressed = Global.hide_bots


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
	GameEvents.emit_encounter_variable_saved("settings", "p3_boa_strat", index)
	

func _on_starting_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("settings", "p3_boa_start_point", index)


func _on_invuln_button_pressed() -> void:
	pass


func _on_hide_bots_check_button_pressed() -> void:
	Global.hide_bots = hide_bots_check_button.button_pressed
	toggle_bots_visible.emit()
