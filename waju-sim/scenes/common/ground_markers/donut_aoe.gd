# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends GroundMarker
class_name DonutAoe

var _inner_radius: float

func set_parameters(new_position: Vector3, inner_radius: float, outter_radius: float,
	 lifetime: float, color: Color, fail_conditions: Array = []) -> void:
	is_donut = true
	donut_inner_radius = inner_radius
	set_center_position(new_position)
	set_radius(inner_radius, outter_radius)
	set_color(color)
	set_lifetime(lifetime)
	if fail_conditions.size() > 0:
		set_fail_conditions(fail_conditions)


func set_radius(inner_radius : float, outter_radius : float) -> void:
	mesh_instance_3d.mesh.top_radius = outter_radius
	mesh_instance_3d.mesh.bottom_radius = outter_radius
	var shader_factor := (inner_radius / outter_radius) / 4.0
	mesh_instance_3d.mesh.material.set_shader_parameter("size", shader_factor) 
	collision_shape_3d.shape.radius = outter_radius
	_inner_radius = inner_radius


func set_color(color: Color) -> void:
	mesh_instance_3d.mesh.material.set_shader_parameter("color", color)


# TODO redo collision check
func get_collisions() -> Array:
	#await wait_two_frames()
	var all_bodies := get_overlapping_bodies()
	var bodies_hit := []
	# Filter out bodies within inner radius
	for body in all_bodies:
		var pos := body.global_position
		if pos.distance_squared_to(global_position) > _inner_radius ** 2:
			bodies_hit.append(body)
	return bodies_hit
