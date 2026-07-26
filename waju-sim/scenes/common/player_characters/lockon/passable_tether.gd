# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name PassableTether

const TETHER_TARGET_LOCKON = preload("uid://grl6rtcf6d1x")
const TETHER_HEIGHT := 2.0
var debug := false

@onready var target : Node3D
@onready var source : Node = $".."
@onready var tether_mesh: MeshInstance3D = %TetherMesh

@export var active := false
@export var dynamic := false
var base_color: Color
var dyn_color: Color
var dist_to_target: float
var min_length := 0.0
var last_frame_stretched := false
var initial_check := true

var current_lockon: Node3D
var lockon_node_path := "Lockon"

func _physics_process(_delta: float) -> void:
	if !active or target == null:
		return
	
	look_at_from_position(source.global_position, target.global_position)
	dist_to_target = source.global_position.distance_to(target.global_position)
	scale = Vector3(1.0 / source.scale.x, 1.0 / source.scale.y, 1.0 / source.scale.z * dist_to_target)
	global_position = source.global_position.lerp(target.global_position, 0.5)
	global_position.y = TETHER_HEIGHT
	if debug:
		print(dist_to_target)
	# Dynamic coloring
	if dynamic:
		if dist_to_target < min_length:
			if last_frame_stretched or initial_check:
				self.mesh.material.albedo_color = dyn_color
				last_frame_stretched = false
		elif !last_frame_stretched or initial_check:
			self.mesh.material.albedo_color = base_color
			last_frame_stretched = true
		initial_check = false


func get_target() -> Node3D:
	if !target:
		return null
	return target


func set_size(new_size: float) -> void:
	tether_mesh.mesh.size.x = new_size
	tether_mesh.mesh.size.y = new_size


func set_target(new_target: Node3D) -> void:
	target = new_target
	set_lockon()

func set_source(new_source: Node3D) -> void:
	source = new_source


func set_color(new_color: Color) -> void:
	base_color = new_color
	self.mesh.material.albedo_color = base_color


# If tether is shorter than min_length, color will change to dynamic color.
func set_dynamic_color(new_color: Color, new_min_length: float) -> void:
	dyn_color = new_color
	min_length = new_min_length
	dynamic = true


func get_dist_to_target() -> float:
	return dist_to_target


func set_lockon():
	if current_lockon:
		remove_lockon()
	current_lockon = TETHER_TARGET_LOCKON.instantiate()
	target.get_node(lockon_node_path).add_child(current_lockon)


func remove_lockon():
	current_lockon.queue_free()


func _on_area_3d_body_entered(new_body: Node3D) -> void:
	print(new_body.get_role_name() + " entered tether.")
	if new_body is not PlayableCharacter or new_body == target:
		return
	set_target(new_body)
