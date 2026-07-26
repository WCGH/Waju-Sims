# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends GroundMarker
class_name ConeAoe

const CONE_HEIGHT := 0.11

var _length : float


func set_parameters(new_position: Vector3, angle_deg: float, length: float,
	target: Vector2, lifetime: float, color: Color, fail_conditions: Array = []) -> void:
	set_center_position(new_position)
	set_cone(angle_deg, length, target)
	set_color(color)
	set_lifetime(lifetime)
	if fail_conditions.size() > 0:
		set_fail_conditions(fail_conditions)


func set_cone(angle_deg: float, length: float, target: Vector2) -> void:
	_length = -length
	mesh_instance_3d.mesh.size.x = tan(deg_to_rad(angle_deg / 2.0)) * length
	mesh_instance_3d.scale.y = _length
	mesh_instance_3d.position.z = _length / 2.0
	collision_shape_3d.scale.y = _length
	collision_shape_3d.position.z = _length / 2.0
	# Idk man.
	mesh_instance_3d.create_convex_collision()
	var convex_shape : Node = mesh_instance_3d.get_node("MeshInstance3D_col/CollisionShape3D")
	collision_shape_3d.shape = convex_shape.shape
	mesh_instance_3d.get_node("MeshInstance3D_col").queue_free()
	
	# Rotate to face target
	look_at(Vector3(target.x, CONE_HEIGHT, target.y))


func play_start_animation() -> void:
	mesh_instance_3d.position.z = 0
	mesh_instance_3d.scale = Vector3(0.1, 0.1, 1)
	var tween: Tween = create_tween().set_parallel(true)
	tween.tween_property(mesh_instance_3d, "scale", Vector3(1, _length, 1), 0.15)
	tween.tween_property(mesh_instance_3d, "position", Vector3(0, 0, _length / 2.0), 0.15)
