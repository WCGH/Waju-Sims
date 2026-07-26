# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name Puddle


@export var circle_aoe_scene : PackedScene
@onready var drop_timer: Timer = $DropTimer

@onready var marker_layer : Node3D = get_tree().get_first_node_in_group("ground_marker_layer")

var target : CharacterBody3D
var duration: float
var puddle_count: int
var delay: float
var radius: float
var color := Color.ORANGE_RED
var target_fail_count := 1


func instantiate_puddle(_target: PlayableCharacter, _puddle_count: int,
	drop_delay: float, new_duration: float, _radius: float, _color: Color, _target_fail_count: int) -> void:
	# Check if we got a valid marker layer (sometimes load orded messes with this)
	if !marker_layer:
		marker_layer = get_tree().get_first_node_in_group("ground_marker_layer")
	# Set variables
	target = _target
	puddle_count = _puddle_count
	delay = drop_delay
	duration = new_duration
	radius = _radius
	color = _color
	target_fail_count = _target_fail_count
	# Spawn first puddle
	drop()


func drop() -> void:
	spawn_circle()
	puddle_count -= 1
	if puddle_count < 1:
		# Handle any post puddle stuff here.
		pass
	else:
		# Set timer for next puddle drop
		drop_timer.start(delay)


func _on_drop_timer_timeout() -> void:
	drop()


# TODO: add proper eruption delay to fail/collision check
func spawn_circle() -> CircleAoe:
	var circle_pos = v2(target.global_position)
	var new_circle: CircleAoe = circle_aoe_scene.instantiate()
	marker_layer.add_child(new_circle)
	new_circle.set_parameters(Vector3(circle_pos.x, 0, circle_pos.y), radius,
		duration, color, [0, target_fail_count, "Luminous Hammer (Puddles)", [target]])
	#new_circle.play_start_animation()
	new_circle.await_collision()
	return new_circle


func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
