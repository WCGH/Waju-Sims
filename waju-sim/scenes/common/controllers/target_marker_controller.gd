# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name TargetMarkerController

@export var marker_scene_paths := {
	"tar_1": "res://scenes/common/player_characters/lockon/target_markers/tar_1.tscn",
	"tar_2": "res://scenes/common/player_characters/lockon/target_markers/tar_2.tscn",
	"tar_3": "res://scenes/common/player_characters/lockon/target_markers/tar_3.tscn",
	"tar_4": "res://scenes/common/player_characters/lockon/target_markers/tar_4.tscn",
	"stop_1": "res://scenes/common/player_characters/lockon/target_markers/stop_1.tscn",
	"stop_2": "res://scenes/common/player_characters/lockon/target_markers/stop_2.tscn",
	"link_1": "res://scenes/common/player_characters/lockon/target_markers/link_1.tscn",
	"link_2": "res://scenes/common/player_characters/lockon/target_markers/link_2.tscn",
	"triangle": "res://scenes/common/player_characters/lockon/target_markers/mark_triangle.tscn",
	"circle": "res://scenes/common/player_characters/lockon/target_markers/mark_circle.tscn",
	"square": "res://scenes/common/player_characters/lockon/target_markers/mark_square.tscn",
	"cross": "res://scenes/common/player_characters/lockon/target_markers/mark_cross.tscn"
	}

var marker_scenes: Dictionary
var active_markers: Array
var lockon_marker_path := "Lockon/TargetMarker"


func _ready() -> void:
	for key: String in marker_scene_paths:
		ResourceLoader.load_threaded_request(marker_scene_paths[key])


func add_marker(marker_key: String, target: PlayableCharacter) -> void:
	# Remove existing markers.
	remove_markers(target)
	# Add new marker
	if !marker_scenes.has(marker_key):
		assert(marker_scene_paths.has(marker_key), "Error: Invalid marker key.")
		marker_scenes[marker_key] = ResourceLoader.load_threaded_get(marker_scene_paths[marker_key])
	var new_marker: Node3D = marker_scenes[marker_key].instantiate()
	target.get_node(lockon_marker_path).add_child(new_marker)
	active_markers.append(new_marker)


func remove_markers(target: Node3D) -> void:
	var marker_node: Node3D = target.get_node(lockon_marker_path)
	if marker_node.get_child_count() > 0:
		var active_marker: Node3D = marker_node.get_child(0)
		active_markers.erase(active_marker)
		active_marker.queue_free()


func remove_all_markers() -> void:
	for active_marker: Node3D in active_markers:
		active_marker.queue_free()
	active_markers = []
