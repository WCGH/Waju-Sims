# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

var player_key: String


func get_key() -> String:
	return player_key


func set_key(key: String) -> void:
	player_key = key
