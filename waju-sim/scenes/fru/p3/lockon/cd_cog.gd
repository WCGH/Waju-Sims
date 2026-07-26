# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name CDCog

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func start_countdown():
	animation_player.play("countdown")


func free_self():
	self.queue_free()
