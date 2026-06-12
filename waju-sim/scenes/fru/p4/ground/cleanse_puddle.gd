# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name CleansePuddle

signal on_puddle_collision(body: Node3D)

const TIMEOUT_TIME := 17.8

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hitbox: Area3D = $Hitbox
@onready var puddle_timeout: Timer = %PuddleTimeout

var active := false
var dropper_key: String


func _ready() -> void:
	animation_player.play("fade_in")
	puddle_timeout.start(TIMEOUT_TIME)
	# Delay active timer
	await get_tree().create_timer(1.0).timeout
	active = true
	# Check if there's someone already in the puddle (on_entered might not trigger).
	if hitbox.has_overlapping_bodies():
		_on_hitbox_body_entered(hitbox.get_overlapping_bodies()[0])


# We store who soaked dragon to drop this puddle to determine who should soak this puddle.
func get_dropper() -> String:
	return dropper_key


func set_dropper(dropper: String):
	dropper_key = dropper


func _on_hitbox_body_entered(body: Node3D) -> void:
	if !active:
		return
	on_puddle_collision.emit(body)
	active = false
	animation_player.play("fade_out")


func _on_puddle_timeout_timeout() -> void:
	active = false
	animation_player.play("fade_out")


func remove_puddle() -> void:
	self.queue_free()
