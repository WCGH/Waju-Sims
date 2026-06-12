# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Don't confuse with "exaflares.gd" sequence script.

extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow_animation_player: AnimationPlayer = %ArrowAnimationPlayer

#func fade_in() -> void:
	#animation_player.play("fade_in")


# Don't queue free yet, need references to position and basis.
func fade_out() -> void:
	arrow_animation_player.get_animation("arrow_pulse").loop_mode = Animation.LOOP_NONE
	animation_player.play("fade_out")
