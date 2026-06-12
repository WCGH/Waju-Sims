# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Handles show/hide animations for P4 Hourglass and Tethers.

extends Node3D

class_name HourglassBlue

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func show_hourglass() -> void:
	animation_player.play("fade_in")


func hide_hourglass() -> void:
	animation_player.play("fade_out")


func show_purple_tether() -> void:
	animation_player.play("grow_in_purple_tether")


func show_yellow_tether() -> void:
	animation_player.play("grow_in_yellow_tether")


func hide_tether() -> void:
	animation_player.play("fade_out_tethers")
