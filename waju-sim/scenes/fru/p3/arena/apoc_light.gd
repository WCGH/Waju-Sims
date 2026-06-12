# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name ApocLight

#const SPEED := 0.3927  # (2 * PI) / 16

var facing_direction: int
var radius: float
var base_rotation: float
var angle := 0.0
var active := false
var max_angle_deg: float
var speed: float
var n_light: bool

func _ready() -> void:
	set_process(false)


func _process(delta: float) -> void:
	angle += speed * delta * facing_direction
	self.rotation.y = base_rotation - angle
	if n_light:
		self.position.x = radius * cos(angle)
		self.position.z = radius * sin(angle)
	else:
		self.position.x = radius * cos(angle) * -1
		self.position.z = radius * sin(angle) * -1
	# Handle max rotation (TODO: cleared manually for now)
	#if abs(angle) > deg_to_rad(max_angle_deg) * 2.0 * PI:
		#self.queue_free()


func start(start_pos: Vector3, rotate_cw: bool, rotation_deg, rotation_time, first_ring: bool, north_light: bool):
	n_light = north_light
	speed = (2.0 * PI) / (rotation_time * 8)
	self.visible = true
	# All light except first need to move from center to starting position
	if !first_ring:
		var tween : Tween = get_tree().create_tween()
		tween.tween_property(self, "position",
			Vector3(start_pos.x, 0, start_pos.y), rotation_time)\
			.set_trans(Tween.TRANS_LINEAR)
		# TODO/DEBUG: need to make sure this awaits correctly.
		await tween.finished
	# Set light to starting position/rotation
	self.position = Vector3(start_pos.x, 0, start_pos.y)
	self.rotation.y = deg_to_rad(90.0)
	start_circle(rotate_cw, rotation_deg)


func start_circle(cw: bool, max_angle_traveled_deg: float) -> void:
	# Need to set starting rotation before calling this function
	base_rotation = rotation.y
	max_angle_deg = max_angle_traveled_deg
	radius = abs(position.x)
	active = true
	facing_direction = 1 if cw else -1
	set_process(true)
