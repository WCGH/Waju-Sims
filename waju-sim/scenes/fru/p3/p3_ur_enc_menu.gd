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
@onready var debuff_select_button: OptionButton = %DebuffSelectButton


func _ready() -> void:
	lineup_button.selected = FruSavedVariables.save_data["settings"]["p3_ur_strat"]
	debuff_select_button.selected = FruGlobal.p3_selected_debuff


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
	GameEvents.emit_encounter_variable_saved("settings", "p3_ur_strat", index)


func _on_debuff_select_button_item_selected(index: int) -> void:
	FruGlobal.p3_selected_debuff = index
