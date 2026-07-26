# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name UsurperWings

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_show():
	animation_player.play("show")


func play_hide():
	animation_player.play("hide")
