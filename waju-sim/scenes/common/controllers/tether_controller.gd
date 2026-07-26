# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name TetherController

var base_tether_path := "uid://jl8oj6r0qdvu"
var passable_tether_path := "uid://c1qot0oeax7o6"
var tether_path := base_tether_path
var tether_scene : PackedScene
var active_tethers : Array




func preload_resources(is_passable := false) -> void:
	if is_passable:
		tether_path = passable_tether_path
	else:
		tether_path = base_tether_path
	ResourceLoader.load_threaded_request(tether_path, "PackedScene")


# If dynamic color is set, tether will switch to that color when < min_length.
func spawn_tether(source: Node3D, target: Node3D,
	color: Color = Color.BLACK, dynamic_color: Color = Color.BLACK,
	min_length: float = 0.0, size: float = 0.1, is_passable := false) -> Node3D:
	if !tether_scene:
		if is_passable:
			tether_path = passable_tether_path
		tether_scene = ResourceLoader.load_threaded_get(tether_path)
	var new_tether = tether_scene.instantiate()
	source.add_child(new_tether)
	new_tether.set_source(source)
	new_tether.set_target(target)
	new_tether.set_size(size)
	if color != Color.BLACK:
		new_tether.set_color(color)
	if dynamic_color != Color.BLACK:
		new_tether.set_dynamic_color(dynamic_color, min_length)
	new_tether.visible = true
	new_tether.active = true
	active_tethers.append(new_tether)
	return new_tether


# Removes all tethers connected to source.
# Needs to be updated to handle multiple tethers on one target.
func remove_tether(source: Node3D) -> void:
	for i in active_tethers.size():
		if active_tethers.get(i) == null:
			continue
		if active_tethers[i].source == source:
			var tether = active_tethers.pop_at(i)
			tether.remove_lockon()
			tether.queue_free()
			return


func get_tether(source: Node3D):
	for tether in active_tethers:
		if !tether:
			continue
		if tether.source == source:
			return tether
	return null


func remove_all_tethers() -> void:
	for i in active_tethers.size():
		var tether = active_tethers.pop_back()
		if !tether:
			continue
		tether.remove_lockon()
		tether.queue_free()
	active_tethers.clear()


func get_tether_target(source: Node3D) -> Node3D:
	for tether in active_tethers:
		if !tether:
			continue
		if tether.source == source:
			if tether is not PassableTether:
				return null
			return tether.get_target()
	return null
			


func set_tether_target(source: Node3D, target: Node3D) -> void:
	for tether in active_tethers:
		if tether.source == source:
			tether.set_target(target)
