# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name ThordanAnimation

@onready var jump_animation_player: AnimationPlayer = %JumpAnimationPlayer
@onready var animation_sequence: AnimationPlayer = %AnimationSequence
@onready var thordan: Node3D = get_parent()

func start_jump() -> void:
	animation_sequence.play("jump")


func play_cast_amim() -> void:
	jump_animation_player.play("cbbm_sp08_Armature")


func play_jump_anim() -> void:
	jump_animation_player.play("cbbm_sp18_Armature")


func tween_y_pos() -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", Vector3(0, 20, 0), 0.3)


func reset_pos() -> void:
	thordan.visible = false
	position = Vector3(0, 0, 0)
