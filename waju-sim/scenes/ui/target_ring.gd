# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func play_grow_in() -> void:
	animation_player.play("grow_in")
