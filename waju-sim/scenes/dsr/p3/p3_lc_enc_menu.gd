# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.


extends CanvasLayer


enum InLine {RAND, LC1, LC2, LC3}
enum Arrow {RAND, UP, CIRCLE, DOWN}

@onready var encounter_config_button: TextureButton = %EncounterConfigButton
@onready var strat_margin_container: MarginContainer = %StratMarginContainer
@onready var mit_check_margin_container: MarginContainer = %MitCheckMarginContainer
@onready var strat_button: OptionButton = %StratButton
@onready var in_line_button: OptionButton = %InLineButton
@onready var arrow_button: OptionButton = %ArrowButton


func _ready() -> void:
	strat_button.selected = DsrSavedVariables.save_data["p3"]["nidhogg"]
	in_line_button.selected = DsrGlobal.p3_in_line
	validate_circle_arrow()
	arrow_button.selected = DsrGlobal.p3_arrow


func _on_encounter_config_button_pressed() -> void:
	toggle_encounter_menu()


func _on_close_button_pressed() -> void:
	hide_menu()


func _on_strat_button_item_selected(index: int) -> void:
	GameEvents.emit_encounter_variable_saved("p3", "nidhogg", index)


func _on_in_line_button_item_selected(index: int) -> void:
	DsrGlobal.p3_in_line = index
	validate_circle_arrow()


func _on_arrow_button_item_selected(index: int) -> void:
	DsrGlobal.p3_arrow = index


func validate_circle_arrow():
	# If LC2 disable Circle arrow option.
	if DsrGlobal.p3_in_line == InLine.LC2:
		arrow_button.set("popup/item_2/disabled", true)
		# If Circle is selected, change it to default (random).
		if DsrGlobal.p3_arrow == Arrow.CIRCLE:
			DsrGlobal.p3_arrow = Arrow.RAND
			arrow_button.selected = Arrow.RAND
	else:
		arrow_button.set("popup/item_2/disabled", false)


func close_mit_menu():
	mit_check_margin_container.hide()
	strat_margin_container.show()


func toggle_encounter_menu():
	close_mit_menu()
	self.visible = !self.visible


func hide_menu():
	close_mit_menu()
	self.hide()
