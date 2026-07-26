# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Lockon Controller
## Handles the loading and instantiation of lockon nodes.
## When adding a new lockon node:
##  - Add node to enums.
##  - Add res path and meta id#.
##  - Add meta id# to root node in new lockon scene.

# TODO: Add hide/show functionality here if we need in the future.

extends Node
class_name LockonController

enum {PS_CROSS, PS_CIRCLE, PS_SQUARE, PS_TRIANGLE,
	DEFAM, DIVEBOMB, DOOM, LC_1, LC_2, LC_3, LR_ORB,
	SPREAD_MARKER, GAZE, STACK_MARKER, CD_COG, SPREAD_MARKER_APOC,
	CONE, STACK, TARGET, LC_4, LC_5, LC_6, LC_7, LC_8}

var res_paths := {
	PS_CROSS: "uid://dctfiflorcw48",
	PS_CIRCLE: "uid://bw07f2cpvri54",
	PS_SQUARE: "uid://cw8bjk355jwpi",
	PS_TRIANGLE: "uid://c3dyjnqrnqerx",
	DEFAM: "uid://vwrrhcnicpnt",
	DIVEBOMB: "uid://by718qkef1wkf",
	DOOM: "uid://ci5mcbksuknt",
	LC_1: "uid://d10jgdh6krdej",
	LC_2: "uid://blfvw0lx5ewbv",
	LC_3: "uid://cryha54258ujw",
	LR_ORB: "uid://spagx0n2okdd",
	SPREAD_MARKER: "uid://byalbsv700s12",
	GAZE: "uid://ce1rukdbuak61",
	STACK_MARKER: "uid://fsk7o8ky2v7e",
	CD_COG: "uid://b8xivjyxyvvkd",
	SPREAD_MARKER_APOC: "uid://dvbq0uw7rv0l8",
	CONE: "uid://fiqgmde1atj1",
	STACK: "uid://brg8ik1vo4thu",
	TARGET: "uid://b317aqshya88u",
	LC_4: "uid://7nyik6sqgseg",
	LC_5: "uid://8qdgldl2qfs0",
	LC_6: "uid://ddetqm63402tf",
	LC_7: "uid://8il8726baoq8",
	LC_8: "uid://douybqysqel5p",
}

var meta_ids := {
	PS_CROSS: 0, PS_CIRCLE: 1, PS_SQUARE: 2, PS_TRIANGLE: 3,
	DEFAM: 4, DIVEBOMB: 5, DOOM: 6, LC_1: 7, LC_2: 8, LC_3: 9, 
	LR_ORB: 10, SPREAD_MARKER: 11, GAZE: 12, STACK_MARKER: 13, CD_COG: 14,
	SPREAD_MARKER_APOC: 15, CONE: 16, STACK: 17, TARGET: 18,
	LC_4: 19, LC_5: 20, LC_6: 21, LC_7: 22, LC_8: 23,
}

var lockon_node_path := "Lockon"
var loaded_scenes: Dictionary


func pre_load(lockon_id_list: Array) -> void:
	for lockon_id: int in lockon_id_list:
		ResourceLoader.load_threaded_request(res_paths[lockon_id])


# If null instance, make sure you pre_loaded the lockon.
func add_marker(lockon_id: int, target: Node3D) -> Node3D:
	assert(target.get_node(lockon_node_path), "Error. Missing lockon node (invalid path?).")
	if !loaded_scenes.has(lockon_id):
		loaded_scenes[lockon_id] = ResourceLoader.load_threaded_get(res_paths[lockon_id])
	var new_marker: Node3D = loaded_scenes[lockon_id].instantiate()
	target.get_node(lockon_node_path).add_child(new_marker)
	return new_marker


# Returns true if successful.
func remove_marker(lockon_id: int, target: Node3D) -> bool:
	assert(target.get_node(lockon_node_path), "Error. Missing lockon node (invalid path?).")
	var lockon_nodes := target.get_node(lockon_node_path).get_children()
	for node in lockon_nodes:
		assert(node.has_meta("id"), "Error. Missing lockon node meta data (id).")
		if node.get_meta("id") == meta_ids[lockon_id]:
			node.queue_free()
			return true
	return false
