# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Camera3D

const RAY_LENGTH := 900000.0
const COLLISION_MASK := 16
const FLOOR_MASK := 128


func get_first_ray_collision(mouse_position: Vector2) -> Dictionary:
	var from := project_ray_origin(mouse_position)
	var to := from + project_ray_normal(mouse_position) * RAY_LENGTH
	var space := get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = COLLISION_MASK
	ray_query.collide_with_areas = true
	return space.intersect_ray(ray_query)


func get_first_ray_collision_with_floor(mouse_position: Vector2) -> Dictionary:
	var from := project_ray_origin(mouse_position)
	var to := from + project_ray_normal(mouse_position) * RAY_LENGTH
	var space := get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.new()
	ray_query.from = from
	ray_query.to = to
	ray_query.collision_mask = FLOOR_MASK
	ray_query.collide_with_areas = true
	return space.intersect_ray(ray_query)
