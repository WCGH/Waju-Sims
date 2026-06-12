# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MarginContainer

@onready var buttons_vbox: VBoxContainer = $MarginContainer/LeftButtonsVBox
@onready var options_menu_container: MarginContainer = %OptionsMenuContainer
@onready var containers := {
	"t1": %T1Container, "t2": %T2Container, "h1": %H1Container, "h2": %H2Container,
	"m1": %M1Container, "m2": %M2Container, "r1": %R1Container, "r2": %R2Container
}
var lineup_keys: Array


func _ready() -> void:
	lineup_keys = SavedVariables.save_data["p5"]["lineup"]
	order_containers()


func order_containers() -> void:
	for i in lineup_keys.size():
		buttons_vbox.move_child(containers[lineup_keys[i]], i + 2)


func save_lineup() -> void:
	GameEvents.emit_variable_saved("p5", "lineup", lineup_keys)


func _on_default_button_pressed() -> void:
	lineup_keys = Global.default_lineup.duplicate()
	order_containers()
	save_lineup()


func _on_back_button_pressed() -> void:
	self.hide()
	options_menu_container.show()
