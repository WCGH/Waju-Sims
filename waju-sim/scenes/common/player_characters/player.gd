# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Player Controller
## Instantiate alongside set_parameters.

extends PlayableCharacter
class_name Player

signal target_changed(target: Node3D)

var debug := false
#@export var player_scale : float = 1.25
#@export var model_scene : PackedScene

@onready var player_movement_controller: PlayerMovementController = %PlayerMovementController
@onready var camera : Camera3D = %Camera3D



#func _ready() -> void:
	#model = model_scene.instantiate()
	#add_child(model)
	
	#model.scale = Vector3.ONE * model_scale
	#anim_tree = model.get_node("AnimationTree")
	#anim_state = model.get_node("AnimationTree").get("parameters/playback")


func set_parameters(new_role_key : String, new_model_scene : PackedScene, 
	spawn_position : Vector3) -> void:
	model_scene = new_model_scene
	role_key = new_role_key
	position = spawn_position
	is_player_character = true


func set_model_meta(meta_data) -> void:
	player_movement_controller.xiv_model = meta_data


# Used for left click targetting. Will emit signal if we click on valid hitbox.
func handle_left_click(mouse_pos: Vector2) -> void:
	var ray_result: Dictionary = camera.get_first_ray_collision(mouse_pos)
	if debug:
		print(mouse_pos)
		print(ray_result)
	if ray_result.is_empty():
		target_changed.emit(null)
		return
	var collider: Node3D = ray_result["collider"]
	if collider is Area3D:
		collider = collider.get_parent_node_3d()
	target_changed.emit(collider)


func reset_movement():
	player_movement_controller.reset_player_movement()

#func move_to(vec2 : Vector2) -> void:
	#if debug:
		#print("Error. Script tried to move player to: ", vec2)
	#return


# Used for DSR P3 tower snapshots
#func get_arrow_vector(length: float, arrow: String) -> Vector3:
	#var arrow_vector := Vector3.ZERO
	#arrow_vector.z = -1 if arrow == "up" else 1
	#return global_position + ((model.transform.basis * arrow_vector).normalized() * length)


func get_camera() -> Camera3D:
	return camera

#
#func set_look_direction(_new_look_direction : Vector3) -> void:
	#return


func freeze_player() -> void:
	player_movement_controller.is_frozen = true
	anim_tree.set("parameters/conditions/idle", true)


func unfreeze_player() -> void:
	player_movement_controller.is_frozen = false


func is_player() -> bool:
	return true


func dash() -> void:
	player_movement_controller.dash()


# TODO: Add debuff
func arms_length() -> void:
	player_movement_controller.arms_length()


# TODO: Add debuff
func sprint() -> void:
	player_movement_controller.sprint()


func is_player_frozen() -> bool:
	return player_movement_controller.is_frozen
