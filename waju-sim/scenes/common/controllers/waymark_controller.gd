# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Warning, there's a lot of hardcoded indexes in here. If you want to add more
## preset or custom waymarks to the menu, you'll need to manually change those.

extends Node

class_name WaymarkController

var waymark_keys :={"wm_a": "A", "wm_b": "B", "wm_c": "C", "wm_d": "D",
		"wm_1": "One", "wm_2": "Two", "wm_3": "Three", "wm_4": "Four"}
# Point to default waymark scene.
@export var waymark_scene: PackedScene
# Point to Arena/Waymark node in each new sequence.
@export var arena_waymark_node: Node3D

var wm_scene: Waymarks
var menu_slot_keys := ["preset_1", "preset_2", "preset_3", "custom_1", "custom_2"]
var preset_keys := ["preset_1", "preset_2", "preset_3"]
var custom_slot_names := ["Custom 1", "Custom 2"]  # Warn: do not use for keys


func _ready() -> void:
	var wm_positions: Dictionary
	# Check if we have current waymarks saved in Global (we want to keep waymarks on reloaded scene)
	if Global.get_encounter_waymarks()["current"].is_empty():
		var active_key = SavedVariables.get_encounter_data("waymarks", "active")
		if active_key.contains("custom"):
			wm_positions = SavedVariables.get_encounter_data("waymarks", active_key).duplicate()
		else:
			wm_positions = Global.get_encounter_waymarks()[active_key].duplicate()
		Global.get_encounter_waymarks()["current"] = wm_positions
	else:
		wm_positions = Global.get_encounter_waymarks()["current"].duplicate()
	# Instantiate waymark scene
	wm_scene = waymark_scene.instantiate()
	arena_waymark_node.add_child(wm_scene)
	wm_scene.set_waymarks(wm_positions)


func move_waymark(wm_key: String, new_pos: Vector2):
	wm_scene.move_waymark(wm_key, new_pos)


func clear_wm(wm_key: String):
	wm_scene.hide_wm(wm_key)


func clear_all_wm():
	wm_scene.hide_all()


func set_preset_markers(slot: int):
	# Preset markers from Global
	if slot < preset_keys.size():
		wm_scene.set_waymarks(Global.get_encounter_waymarks()[menu_slot_keys[slot]].duplicate())
	# Custom markers from SavedVariables
	else:
		wm_scene.set_waymarks(SavedVariables.get_encounter_data("waymarks", menu_slot_keys[slot]).duplicate())
	# Save newest selection as "active" waymarks, which will be loaded on launch.
	GameEvents.emit_encounter_variable_saved("waymarks", "active", menu_slot_keys[slot])


func save_custom_preset(slot: int):
	assert(slot > 2, "Error. Tried to save custom Waymarks to a preset slot index.")
	GameEvents.emit_encounter_variable_saved("waymarks", "active", menu_slot_keys[slot])
	GameEvents.emit_encounter_variable_saved("waymarks", menu_slot_keys[slot], wm_scene.get_active_wm_positions())


# Warn: Custom slot index is not the overall slot index.
func save_custom_preset_from_import(waymarks: Dictionary, custom_slot: int):
	# Needs to be changed if any preset slots are added/removed.
	custom_slot += preset_keys.size()
	assert (custom_slot > (preset_keys.size() - 1) and custom_slot < menu_slot_keys.size(),
		"Error. Tried to save custom Waymarks to invalid index.")
	GameEvents.emit_encounter_variable_saved("waymarks", menu_slot_keys[custom_slot], waymarks)


# Validates the dictionary data, and depending on active encounter, converts
# FFXIV coordinates into sim coordinates. Returns true if data has "Name" key.
# Warn: Custom slot index is not the overall slot index.
func import_dict_to_custom(data: Dictionary, custom_slot: int) -> bool:
	var waymarks :=  {
		"name": custom_slot_names[custom_slot],
		"wm_a": Waymarks.HIDE_VECTOR, "wm_b": Waymarks.HIDE_VECTOR, "wm_c": Waymarks.HIDE_VECTOR, "wm_d": Waymarks.HIDE_VECTOR,
		"wm_1": Waymarks.HIDE_VECTOR, "wm_2": Waymarks.HIDE_VECTOR, "wm_3": Waymarks.HIDE_VECTOR, "wm_4": Waymarks.HIDE_VECTOR,
	}
	for key in waymark_keys.keys():
		var coords: Dictionary = data.get(waymark_keys[key])
		if coords and coords.has_all(["X", "Z"]) and coords.get("X") is float and coords.get("Z") is float:
			waymarks[key] = convert_coords(Vector2(coords.get("X"), coords.get("Z")))
	save_custom_preset_from_import(waymarks, custom_slot)
	# Can remove this if you don't want markers to be auto set when imported.
	set_preset_markers(custom_slot + preset_keys.size())
	# The return functionality isn't being used since we're updating the label either way.
	if data.has("Name"):
		waymarks["name"] = data["Name"]
		return true
	else:
		return false

# Converts XIV coords to sim coords depending on encounter.
func convert_coords(coords: Vector2) -> Vector2:
	if Global.encounter == Global.Encounter.DSR:
		return Vector2((coords.x - 100) * 2, (coords.y - 100) * 2)
	# For FRU coords need to flip x/y axis, then invert x.
	elif Global.encounter == Global.Encounter.FRU:
		coords = Vector2(coords.y, coords.x)
		return Vector2((100 - coords.x ) * 2.2, (coords.y - 100) * 2.2)
	elif Global.encounter == Global.Encounter.DMU:
		return Vector2((coords.x - 100) * 2.3, (coords.y - 100) * 2.3)
	else:
		return Waymarks.HIDE_VECTOR
