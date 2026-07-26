# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name CrystalizedDragon

signal collided_with_body(pos: Vector3, body: Node3D)

const SPEED := 0.245
var hit_count := 0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var puddle_drop: Node3D = %PuddleDrop


var facing_direction: int
var radius: float
var base_rotation: float
var angle := 0.0
var active := false

func _ready() -> void:
	set_process(false)
	radius = abs(global_position.x)  # Should be defaulted to 30.
	base_rotation = rotation.y


func _process(delta: float) -> void:
	angle += SPEED * delta * facing_direction
	#var new_rotation = base_rotation + (angle_delta * facing_direction)
	self.rotation.y = base_rotation - angle
	self.global_position.x = radius * cos(angle)
	self.global_position.z = radius * sin(angle)
	# Handle max rotations (1 full circle)
	if abs(angle) > 2 * PI:
		self.queue_free()


func start_circle(direction: String) -> void:
	#animation_player.play("idle")
	active = true
	facing_direction = 1 if direction == "e" else -1
	set_process(true)


func play_idle():
	animation_player.play("idle")


func play_fade_in():
	animation_player.play("fade_in")


func play_fade_out():
	animation_player.play("fade_out")


func free_dragon():
	self.queue_free()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if !active:
		return
	collided_with_body.emit(puddle_drop.global_position, body)
	# Check if second hit.
	hit_count += 1
	if hit_count > 1:
		# Prevent multiple triggers during fade out anim.
		active = false
		play_fade_out()
