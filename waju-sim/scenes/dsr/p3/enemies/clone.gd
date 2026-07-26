# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name Clone

@export var dive_height := 30.0
@export var rotation_speed := 0.05

var locked_on := false
var target : Node3D

@onready var nidhogg_anim: Node3D = $NidhoggAnim


func _process(_delta: float) -> void:
	if locked_on:
		var tar_pos := target.global_position
		if tar_pos.x != global_position.x and tar_pos.z != global_position.z:
			global_basis = global_basis.slerp(Basis.looking_at(tar_pos - global_position), rotation_speed)


func play_dive_animation() -> void:
	global_position.y = dive_height
	var target_pos := Vector3(global_position.x, 0.0, global_position.z)
	var tween := create_tween()
	tween.tween_property(self, "position", target_pos, 0.15)


func set_lockon(new_target : Node3D) -> void:
	target = new_target
	locked_on = true


func remove_lockon() -> void:
	locked_on = false


func get_facing_vector() -> Vector3:
	var model_basis := transform.basis
	var arrow_vector := Vector3(0, 1, 0)
	arrow_vector = global_position + ((model_basis * arrow_vector).normalized())
	return arrow_vector
