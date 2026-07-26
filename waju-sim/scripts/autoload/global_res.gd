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


func get_scene(scene_key: String) -> PackedScene:
	if res_data.has(scene_key):
		return res_data[scene_key]
	if !res_paths.has(scene_key):
		push_error("Unknown global resource: %s" % scene_key)
		return null
	res_data[scene_key] = load(res_paths[scene_key])
	return res_data[scene_key]
