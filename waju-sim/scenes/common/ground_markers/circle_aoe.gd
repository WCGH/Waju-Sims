# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends GroundMarker
class_name CircleAoe

signal circle_body_entered(body: CharacterBody3D, circle: CircleAoe)
signal circle_area_entered(area: Area3D, spell_name: String)
var _radius: float

func set_parameters(new_position: Vector3, radius: float, lifetime: float,
color: Color, fail_conditions: Array = [], check_end: bool = false) -> void:
	set_center_position(new_position)
	set_radius(radius)
	set_color(color)
	set_lifetime(lifetime)
	if check_end:
		check_at_end()
	if fail_conditions.size() > 0:
		set_fail_conditions(fail_conditions)


func set_radius(radius : float) -> void:
	_radius = radius
	mesh_instance_3d.mesh.top_radius = radius
	mesh_instance_3d.mesh.bottom_radius = radius
	collision_shape_3d.shape.radius = radius
	#set_grow_animation(radius)


#func set_grow_animation(radius: float):
	#var anim : Animation = animation_player.get_animation("grow_in")
	#anim.track_set_key_value(0, 0, radius / 2)
	#anim.track_set_key_value(0, 1, radius)
	#anim.track_set_key_value(1, 0, radius / 2)
	#anim.track_set_key_value(1, 1, radius)


func play_start_animation() -> void:
	mesh_instance_3d.mesh.top_radius = _radius / 2
	mesh_instance_3d.mesh.bottom_radius = _radius / 2
	var tween := get_tree().create_tween().set_parallel(true)
	tween.tween_property(self, "mesh_instance_3d:mesh:top_radius",_radius, 0.2)
	tween.tween_property(self, "mesh_instance_3d:mesh:bottom_radius",_radius, 0.2)


func _on_body_entered(body: CharacterBody3D) -> void:
	circle_body_entered.emit(body, self)


func _on_area_entered(area: Area3D) -> void:
	circle_area_entered.emit(area, spell_name)


func set_color(color : Color) -> void:
	if color != Color.TRANSPARENT and color.a > 0.99:
		color.a = COLOR_ALPHA
	mesh_instance_3d.mesh.material.albedo_color = color
