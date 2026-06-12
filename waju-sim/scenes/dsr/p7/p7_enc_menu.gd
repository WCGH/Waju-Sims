# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

@onready var strat_button: OptionButton = %StratButton
@onready var force_rare_button: CheckButton = %ForceRareButton
@onready var encounter_config_button: TextureButton = %EncounterConfigButton
@onready var strat_margin_container: MarginContainer = %StratMarginContainer
@onready var mit_check_margin_container: MarginContainer = %MitCheckMarginContainer


func _ready() -> void:
	force_rare_button.set_pressed(DsrGlobal.rare_death_pattern)
	strat_button.selected = DsrSavedVariables.get_data("p5", "dooms")


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


func _on_force_rare_button_pressed() -> void:
	DsrGlobal.rare_death_pattern = !DsrGlobal.rare_death_pattern


func _on_strat_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("p5", "dooms", index)
