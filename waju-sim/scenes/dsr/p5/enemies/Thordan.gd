# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Enemy

#@onready var purple_glow: FogVolume = %PurpleGlow
@onready var gaze: Node3D = %Gaze


func move_enemy(pos : Vector2) -> void:
	global_position = Vector3(pos.x, global_position.y, pos.y)
	

#func toggle_fog() -> void:
	#purple_glow.visible = !purple_glow.visible


func toggle_gaze() -> void:
	gaze.visible = !gaze.visible
