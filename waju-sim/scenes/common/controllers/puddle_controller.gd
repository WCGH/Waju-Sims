# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name PuddleController


@export var puddle_scene : PackedScene


func spawn_puddle(target: PlayableCharacter, puddle_count, drop_delay, duration, radius, color, target_fail_count) -> Puddle:
	var puddle: Puddle = puddle_scene.instantiate()
	self.add_child(puddle)
	puddle.instantiate_puddle(target, puddle_count, drop_delay, duration, radius, color, target_fail_count)
	return puddle
	
