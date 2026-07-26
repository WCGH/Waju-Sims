# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

@onready var halo_animation_player: AnimationPlayer = %HaloAnimationPlayer
@onready var halo: Node3D = %Halo
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func play_orb_anim(orb_count: int) -> void:
	if orb_count == 1:
		halo_animation_player.play("orb_rotate_1")
	else:
		halo_animation_player.play("orb_rotate_4")


func play_hand_down_cast() -> void:
	state_machine.travel("hands_down_cast_loop")


func finish_cast_animation() -> void:
	state_machine.travel("idle")


func hide_halo() -> void:
	halo_animation_player.play("RESET")
