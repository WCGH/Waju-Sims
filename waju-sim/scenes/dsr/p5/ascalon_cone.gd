# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends GroundMarker
class_name AscalonCone

@onready var animation_player : AnimationPlayer = $AnimationPlayer


func set_parameters(new_position: Vector3, target: Vector2, lifetime: float, color: Color, fail_conditions: Array) -> void:
	set_center_position(new_position)
	set_cone(target)
	set_color(color)
	set_lifetime(lifetime)
	set_fail_conditions(fail_conditions)


func set_cone(target: Vector2) -> void:
	# Rotate to face target
	look_at(Vector3(target.x, global_position.y, target.y))


func play_start_animation() -> void:
	animation_player.play("grow_in")
