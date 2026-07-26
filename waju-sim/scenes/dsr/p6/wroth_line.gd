# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

@export var grow_in_duration := 0.1

@onready var flame_orb: MeshInstance3D = $FlameOrb
@onready var flame_orb_2: MeshInstance3D = $FlameOrb2
@onready var flame_orb_3: MeshInstance3D = $FlameOrb3


func grow_in() -> void:
	flame_orb.scale = Vector3.ONE * 0.1
	flame_orb_2.scale = Vector3.ONE * 0.1
	flame_orb_3.scale = Vector3.ONE * 0.1
	self.visible = true
	var tween: Tween = get_tree().create_tween().set_parallel()
	tween.tween_property(flame_orb, "scale", Vector3.ONE, grow_in_duration)
	tween.tween_property(flame_orb_2, "scale", Vector3.ONE, grow_in_duration)
	tween.tween_property(flame_orb_3, "scale", Vector3.ONE, grow_in_duration)


# TEST: check for math error thrown by scale going to zero.
func shrink_out() -> void:
	var tween: Tween = get_tree().create_tween().set_parallel()
	tween.tween_property(flame_orb, "scale", Vector3.ZERO, grow_in_duration)
	tween.tween_property(flame_orb_2, "scale", Vector3.ZERO, grow_in_duration)
	tween.tween_property(flame_orb_3, "scale", Vector3.ZERO, grow_in_duration)
	tween.tween_callback(on_shrink_finished)


# Switch to set visible if we need to reuse the orbs.
func on_shrink_finished() -> void:
	queue_free()
