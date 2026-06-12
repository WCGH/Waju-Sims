# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CharacterBody3D

class_name MoveableBoss

@export var move_speed : = 7.0
@export var min_distance := 84.0

var model: Node3D
var player_target: Node3D
var target_pos: Vector3
var at_target := true
var look_direction := Vector3.ZERO
var is_planted := true
var free_move := false


func _ready() -> void:
	model = get_model()


func _physics_process(_delta: float) -> void:
	if is_planted:
		return
	if !free_move:
		target_pos = player_target.global_position
		look_direction = target_pos
		look_at_direction(look_direction)
		if global_position.distance_squared_to(target_pos) > min_distance:
			at_target = false
			set_moving()
	if !at_target:
		# Move boss
		_move_to_target()
		# Check if arrived
		if global_position.distance_squared_to(target_pos) <= min_distance:
			look_at_direction(look_direction)
			set_idle()
			start_attack()
			at_target = true


# Assign in child node
func get_model() -> Node3D:
	return null


func set_idle():
	pass


func set_moving():
	pass


func start_attack():
	pass


func set_min_distance(_dist: float):
	min_distance = _dist


func _move_to_target() -> void:
	var dir := global_position.direction_to(target_pos)
	velocity.x = dir.x * move_speed
	velocity.z = dir.z * move_speed
	move_and_slide()


func move_to_position(_target_pos : Vector3) -> void:
	at_target = false
	free_move = true
	is_planted = false
	target_pos = _target_pos


func follow_target(_target: Node3D) -> void:
	at_target = false
	free_move = false
	is_planted = false
	player_target = _target


func plant() -> void:
	is_planted = true
	set_idle()


func look_at_direction(direction: Vector3) -> void:
	var look_target := (global_position.direction_to(direction) * 100) + global_position
	look_target.y = 0
	self.look_at(look_target)


func set_look_direction(new_look_direction : Vector3) -> void:
	look_direction = new_look_direction
