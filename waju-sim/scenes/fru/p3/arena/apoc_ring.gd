# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MeshInstance3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func pulse():
	animation_player.play("pulse")
