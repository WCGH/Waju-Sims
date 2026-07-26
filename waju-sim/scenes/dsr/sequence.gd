# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name SequenceDSR

@onready var party_controller : PartyController = $PartyController
@onready var encounter_controller: Node = $EncounterController


func _ready() -> void:
	# Connect to window resize signal.
	#get_tree().get_root().size_changed.connect(on_window_size_changed)
	# Set screen size.
	var screen_res := SavedVariables.get_screen_res()  # If misbehaving, check on_ready order.
	#print("Loading screen_res: ", screen_res)
	get_tree().get_root().borderless = false
	get_tree().get_root().set_size(screen_res)
	get_tree().get_root().move_to_center()
	if SavedVariables.save_data["settings"]["maximized"]:
		#print("setting maximized")
		get_tree().get_root().set_mode(Window.MODE_MAXIMIZED)
	# Start sequence.
	start_new_sequence()


func start_new_sequence() -> void:
	var player_role_index : int = SavedVariables.save_data["settings"]["player_role"]
	var selected_role : String = Global.ROLE_KEYS[player_role_index]
	var party : Dictionary = party_controller.instantiate_party(selected_role)
	encounter_controller.start_encounter(party)


func save_variables() -> void:
	# Save camera zoom
	GameEvents.emit_variable_saved("settings", "camera_distance",
		SavedVariables.save_data["settings"]["camera_distance"])
	on_window_size_changed()


func on_window_size_changed() -> void:
	var maximized := get_tree().get_root().get_mode() == Window.MODE_MAXIMIZED
	GameEvents.emit_variable_saved("settings", "maximized", maximized)
	# Keep old screen_res saved if maximized.
	if maximized:
		return
	var screen_res := get_tree().get_root().get_size()
	GameEvents.emit_variable_saved("settings", "screen_res", screen_res)
	#print("size set to:", SavedVariables.save_data["settings"]["screen_res"])
	#print("maximized: ", maximized)


func _on_reset_button_pressed() -> void:
	save_variables()
	get_tree().reload_current_scene()


func _on_main_menu_button_pressed() -> void:
	save_variables()
	get_tree().change_scene_to_file("res://scenes/encounters/dsr/main_menu.tscn")


func _on_close_requested() -> void:
	save_variables()
	self.queue_free()


func _notification(request: int) -> void:
	if request == NOTIFICATION_WM_CLOSE_REQUEST:
		save_variables()
		get_tree().quit()
