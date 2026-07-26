# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name P6Boss

@onready var target_ring: Node3D = $TargetRing
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func set_active_target() -> void:
	target_ring.play_grow_in()


func remove_active_target() -> void:
	target_ring.visible = false


func move_to(new_pos: Vector2) -> void:
	global_position = Vector3(new_pos.x, global_position.y, new_pos.y)


func toggle_glow() -> void:
	%GlowOrb.visible = !%GlowOrb.visible


func start_breath_cast() -> void:
	state_machine.travel("cast_breath_idle")
	#animation_tree.set("parameters/conditions/cast_finished", false)
	#animation_tree.set("parameters/conditions/cast_breath", true)


func finish_cast() -> void:
	state_machine.travel("idle")

#func finish_breath_cast() -> void:
	#animation_tree.set("parameters/conditions/cast_breath", false)
	#animation_tree.set("parameters/conditions/cast_finished", true)


func start_up_cast() -> void:
	state_machine.travel("cast_up_idle")
	#animation_tree.set("parameters/conditions/cast_finished", false)
	#animation_tree.set("parameters/conditions/cast_up", true)


#func finish_up_cast() -> void:
	#animation_tree.set("parameters/conditions/cast_up", false)
	#animation_tree.set("parameters/conditions/cast_finished", true)


func finish_cast_down() -> void:
	state_machine.travel("cast_down_finished")


# At end: sets visible to false
func start_divebomb() -> void:
	state_machine.travel("divebomb")


# At start: sets visible to true
func warp_in() -> void:
	state_machine.travel("warp_in")


# At end: sets visible to false
func warp_out() -> void:
	state_machine.travel("warp_out")
