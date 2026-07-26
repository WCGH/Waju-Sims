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
@onready var puddles_button: CheckButton = %PuddlesButton


func _ready() -> void:
	strat_button.selected = FruSavedVariables.save_data["settings"]["p2_lr_strat"]
	puddles_button.button_pressed = FruGlobal.p2_force_puddles


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
	GameEvents.emit_encounter_variable_saved("settings", "p2_lr_strat", index)


func _on_puddles_button_pressed() -> void:
	FruGlobal.p2_force_puddles = puddles_button.button_pressed
