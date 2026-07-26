# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MeshInstance3D
class_name LRChain

signal chain_stretched(chain_target: Node3D, chain_source: Node3D)

const CHAIN_HEIGHT := 3.0

var debug := false

@onready var target : Node3D
@onready var source : Node = $".."

@export var active := false

var dist_to_target: float
var min_length := 0.0
var max_length := 9999
var chain_active := false

func _physics_process(_delta: float) -> void:
	if !active or target == null:
		return
	
	look_at_from_position(source.global_position, target.global_position)
	dist_to_target = source.global_position.distance_to(target.global_position)
	scale = Vector3(1.0 / source.scale.x, 1.0 / source.scale.y, 1.0 / source.scale.z * dist_to_target)
	global_position = source.global_position.lerp(target.global_position, 0.5)
	global_position.y = CHAIN_HEIGHT
	if debug:
		print(dist_to_target)
	# Length check
	if chain_active:
		if dist_to_target < min_length or dist_to_target > max_length:
			chain_stretched.emit(target, source)


func set_variables(new_source, new_target, new_max_length, new_min_length, new_size) -> void:
	source = new_source
	target = new_target
	max_length = new_max_length
	min_length = new_min_length
	mesh.size.x = new_size
	mesh.size.y = new_size


func set_chain_active(is_active: bool) -> void:
	chain_active = is_active


func set_size(new_size: float) -> void:
	mesh.size.x = new_size
	mesh.size.y = new_size


func set_target(new_target: Node3D) -> void:
	target = new_target


func set_source(new_source: Node3D) -> void:
	source = new_source


func get_dist_to_target() -> float:
	return dist_to_target
