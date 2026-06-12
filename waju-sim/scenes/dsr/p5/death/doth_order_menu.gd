# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MarginContainer


const HEADER_NODE_COUNT := 1  # Number of nodes in the container before the first role node

@onready var strat_margin_container: MarginContainer = %StratMarginContainer
@onready var buttons_vbox: VBoxContainer = %LeftButtonsVBox
@onready var containers := {
	"t1": %T1Container, "t2": %T2Container, "h1": %H1Container, "h2": %H2Container,
	"m1": %M1Container, "m2": %M2Container, "r1": %R1Container, "r2": %R2Container
}
var party_keys: Array


func _ready() -> void:
	party_keys = DsrSavedVariables.save_data["p5"]["lineup"].duplicate()
	order_containers()


func order_containers() -> void:
	for i in party_keys.size():
		buttons_vbox.move_child(containers[party_keys[i]], i + HEADER_NODE_COUNT)


func save_lineup() -> void:
	GameEvents.emit_encounter_variable_saved("p5", "lineup", party_keys)


func _on_default_button_pressed() -> void:
	party_keys = DsrGlobal.default_lineup.duplicate()
	order_containers()
	save_lineup()


func _on_back_button_pressed() -> void:
	self.hide()
	strat_margin_container.show()
