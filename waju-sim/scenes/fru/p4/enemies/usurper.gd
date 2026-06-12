# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name Usurper

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func play_hands_in_cast() -> void:
	state_machine.travel("hands_in_cast_loop")


func play_hands_in_finish() -> void:
	state_machine.travel("hands_in_cast_finish")


func play_hands_out_cast() -> void:
	state_machine.travel("hands_out_cast_loop")


func play_wings_out_cast() -> void:
	state_machine.travel("wings_out_cast")


func play_wings_out_finish() -> void:
	state_machine.travel("idle")


func play_fade_in() -> void:
	state_machine.travel("fade_in_idle")


func play_fade_out() -> void:
	state_machine.travel("fade_out_idle")


func remove_wings() -> void:
	state_machine.travel("idle_no_wing")


func play_spin_wings() -> void:
	state_machine.travel("spin_wings_out")


func play_short_cast() -> void:
	state_machine.travel("short_cast")
