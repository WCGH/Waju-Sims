# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name Pandora

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func play_fulgent_hit() -> void:
	state_machine.travel("fulgent_hit")


func play_akh_morn_hit() -> void:
	state_machine.travel("akh_morn_hit")


func play_paradise_hit() -> void:
	play_akh_morn_hit()


func play_wings_cast() -> void:
	state_machine.travel("wings_cast")


func play_slash_1() -> void:
	state_machine.travel("slash_1")


func play_slash_2() -> void:
	state_machine.travel("slash_2")


func play_polarizing_hit() -> void:
	state_machine.travel("polarizing_hit")
