# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name Nidhogg

@export_enum("boss:0", "clone:1", "quick dive:2") var role := 1
@export var rotation_speed := 0.05

@onready var animation_tree: AnimationTree = $Model/AnimationTree
@onready var animation_player: AnimationPlayer = $Model/AnimationPlayer
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree.get("parameters/playback")

var target : Node3D
var starting_pos := Vector3.ZERO

func _ready() -> void:
	global_position = starting_pos
	if role == 0:
		state_machine.travel("idle")
	elif role == 1:
		state_machine.travel("dive_in")
	else:
		state_machine.travel("quick_dive")
	set_process(false)


func _process(_delta: float) -> void:
	if !target:
		return
	var tar_pos := target.global_position
	if tar_pos.x != global_position.x and tar_pos.z != global_position.z:
		global_basis = global_basis.slerp(Basis.looking_at(tar_pos - global_position), rotation_speed)


func set_start_position(pos: Vector3) -> void:
	starting_pos = pos


func set_role(new_role: int) -> void:
	role = new_role


func set_lockon(new_target : Node3D) -> void:
	target = new_target
	set_process(true)


func remove_lockon() -> void:
	set_process(false)


func get_facing_vector() -> Vector3:
	var model_basis := transform.basis
	var arrow_vector := Vector3(0, 1, 0)
	# If clones are shooting backwards, switch the sign below and don't ask any questions.
	arrow_vector = global_position - ((model_basis * arrow_vector).normalized())
	return arrow_vector


func start_geir() -> void:
	state_machine.travel("geir_cast_loop")


# Also does warp_out but does not queue_free().
func finish_geir() -> void:
	state_machine.travel("geir_cast_finish")


func start_lg() -> void:
	state_machine.travel("lg_cast_loop")


func finish_lg() -> void:
	state_machine.travel("lg_cast_finish")


func lash_hit() -> void:
	state_machine.travel("lash_hit")


func gnash_hit() -> void:
	state_machine.travel("gnash_hit")


# No casting animation.
func finish_dfg() -> void:
	state_machine.travel("dfg_cast_finish")


func on_warp_out_finished() -> void:
	queue_free()
