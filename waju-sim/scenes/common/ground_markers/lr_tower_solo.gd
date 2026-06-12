# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name LRTower


@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var collision_area_3d: Area3D = $CollisionArea3D
@onready var outter_mesh_highlight: MeshInstance3D = $OutterMeshHighlight

enum SoakState {UNDER, SOAKED, OVER}

var bodies_required := 1
var soaked := SoakState.UNDER
var bodies := 0
var lifetime := 10.0
var bodies_array: Array[PlayableCharacter] = []


func set_parameters(pos: Vector3, _lifetime: float):
	self.global_position = pos
	lifetime = _lifetime


# Defaults to 8s drop. TODO: add variable drop timer
func play_start_animation() -> void:
	animation_player.play("orb_drop")
	#await get_tree().create_timer(lifetime).timeout
	#self.queue_free()


func get_bodies() -> Array:
	return bodies_array


func get_soaked_status() -> SoakState:
	return soaked


func set_bodies_required(new_bodies_required: int) -> void:
	bodies_required = new_bodies_required
	check_bodies()


func _on_collision_area_3d_body_entered(body: Node3D) -> void:
	bodies += 1
	bodies_array.append(body)
	check_bodies()


func _on_collision_area_3d_body_exited(body: Node3D) -> void:
	bodies -= 1
	bodies_array.erase(body)
	check_bodies()


func check_bodies() -> void:
	if bodies < bodies_required:
		outter_mesh_highlight.visible = false
		soaked = SoakState.UNDER
	elif bodies == bodies_required:
		outter_mesh_highlight.visible = true
		soaked = SoakState.SOAKED
	else:
		outter_mesh_highlight.visible = true
		soaked = SoakState.OVER
