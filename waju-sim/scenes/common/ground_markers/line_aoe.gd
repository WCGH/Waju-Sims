# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends GroundMarker
class_name LineAoe

# Set to 1.0 if things break.
const COLLISION_SHAPE_HEIGHT := 10.0

var _width: float
var _length: float

func set_parameters(new_position: Vector3, width: float, length: float,
	target: Vector2, lifetime: float, color: Color, fail_conditions: Array = []) -> void:
	set_center_position(new_position)
	set_rect(width, length, target)
	set_color(color)
	set_lifetime(lifetime)
	if fail_conditions.size() > 0:
		set_fail_conditions(fail_conditions)


func set_rect(width: float, length: float, target: Vector2) -> void:
	_width = width
	_length = length
	mesh_instance_3d.mesh.size = Vector2(width * 2, length)
	mesh_instance_3d.mesh.center_offset = Vector3(0, 0, length / 2)
	collision_shape_3d.shape.size = Vector3(width, COLLISION_SHAPE_HEIGHT, length)
	collision_shape_3d.position = Vector3(0, 0, length / 2)
	# Rotate to face target
	var v2_pos := Vector2(global_position.x, global_position.z)
	var angle := (v2_pos.angle_to_point(target) - deg_to_rad(90))
	rotation = Vector3(0, -angle, 0)


func play_start_animation() -> void:
	mesh_instance_3d.mesh.size = Vector2(_width / 2, _length)
	var tween := get_tree().create_tween()
	tween.tween_property(self, "mesh_instance_3d:mesh:size", Vector2(_width, _length), 0.2)
	#var anim : Animation = animation_player.get_animation("grow_in")
	#anim.track_set_key_value(0, 0, Vector2(width / 2, length))
	#anim.track_set_key_value(0, 1, Vector2(width, length))
	#return
