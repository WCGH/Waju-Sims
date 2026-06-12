# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

@onready var top_arrow: Node3D = %TopArrow

var camera: Camera3D


func _ready() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		camera = player.get_camera()


func _process(_delta: float) -> void:
	if !camera:
		set_process(false)
		return
	top_arrow.look_at(Vector3(camera.global_position.x, top_arrow.global_position.y, camera.global_position.z))
	top_arrow.rotation.x = deg_to_rad(-90.0)
