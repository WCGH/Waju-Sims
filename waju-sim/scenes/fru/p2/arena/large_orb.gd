# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name P2LargeOrb

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_orb_spawn():
	animation_player.play("orb_grow_in")


func play_tele_spawn():
	animation_player.play("tele_grow_in")
	
