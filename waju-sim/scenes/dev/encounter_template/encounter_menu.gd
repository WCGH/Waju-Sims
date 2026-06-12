# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.


extends CanvasLayer

@onready var encounter_config_button: TextureButton = %EncounterConfigButton


func _on_encounter_config_button_pressed() -> void:
	toggle_encounter_menu()


func toggle_encounter_menu():
	self.visible = !self.visible
