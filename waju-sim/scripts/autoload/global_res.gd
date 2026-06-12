# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Stores large assets globally, so they aren't reloaded on each reset.
## NOTE: This is a template. Make unique copy for each encounter.
## TODO: Add to autoload in project settings.

extends Node

var res_paths := {
	"dkt": "uid://bul486qjg22n4"
}

var res_data := {}


func _ready() -> void:
	for key: String in res_paths:
		ResourceLoader.load_threaded_request(res_paths[key])


func get_scene(scene_key: String) -> PackedScene:
	if res_data.has(scene_key):
		return res_data[scene_key]
	else:
		if ResourceLoader.load_threaded_get_status(res_paths[scene_key]) !=\
			ResourceLoader.THREAD_LOAD_LOADED:
			print("Global Res scene not loaded.")
		res_data[scene_key] = ResourceLoader.load_threaded_get(res_paths[scene_key])
		return res_data[scene_key]
