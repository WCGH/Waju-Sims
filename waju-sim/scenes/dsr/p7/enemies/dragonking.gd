# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name P7Boss

@onready var target_circle: Node3D = $TargetCircle
@onready var sword_animation_player: AnimationPlayer = %SwordAnimationPlayer
@onready var animation_tree: AnimationTree = $DKT_model/AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

func toggle_target() -> void:
	target_circle.visible = !target_circle.visible


func start_exa_cast() -> void:
	state_machine.travel("exaflare_cast")


func finish_exa_cast() -> void:
	state_machine.travel("exaflare_finish")


func start_wep_glow(is_fire: bool) -> void:
	if is_fire:
		sword_animation_player.play("glow_red")
	else:
		sword_animation_player.play("glow_blue")
