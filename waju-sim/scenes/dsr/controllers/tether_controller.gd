# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name TetherControllerDSR

var tether_path := "res://scenes/markers/lockon/tether.tscn"
var tether_scene : PackedScene
var active_tethers : Array


func preload_resources() -> void:
	ResourceLoader.load_threaded_request(tether_path, "PackedScene")


# If dynamic color is set, tether will switch to that color when < min_length.
func spawn_tether(source: Node3D, target: Node3D,
	color: Color = Color.BLACK, dynamic_color: Color = Color.BLACK,
	min_length: float = 0.0, size: float = 0.1) -> Tether:
	if !tether_scene:
		tether_scene = ResourceLoader.load_threaded_get(tether_path)
	var new_tether: Tether = tether_scene.instantiate()
	new_tether.set_source(source)
	new_tether.set_target(target)
	new_tether.set_size(size)
	if color != Color.BLACK:
		new_tether.set_color(color)
	if dynamic_color != Color.BLACK:
		new_tether.set_dynamic_color(dynamic_color, min_length)
	new_tether.visible = true
	new_tether.active = true
	source.add_child(new_tether)
	active_tethers.append(new_tether)
	return new_tether


# Removes all tethers connected to source.
# Needs to be updated to handle multiple tethers on one target.
func remove_tether(source: Node3D) -> void:
	for tether: Tether in active_tethers:
		if tether.source == source:
			tether.queue_free()


func remove_all_tethers() -> void:
	for i in active_tethers.size():
		var tether: Tether = active_tethers.pop_back()
		tether.queue_free()
