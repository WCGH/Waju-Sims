# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D
class_name Enemy

func move_enemy(pos : Vector2) -> void:
	global_position = Vector3(pos.x, global_position.y, pos.y)
