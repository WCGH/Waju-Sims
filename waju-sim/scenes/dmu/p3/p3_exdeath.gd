# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MoveableBoss

@onready var animation_player: AnimationPlayer = $ExdeathHitboxRing/AnimationPlayer
@onready var exdeath_model: Node3D = %ExdeathModel
@onready var exdeath_hitbox_ring: Node3D = %ExdeathHitboxRing


func set_active_target() -> void:
	animation_player.play("grow_in")


func remove_active_target() -> void:
	exdeath_hitbox_ring.hide()


func get_model() -> Node3D:
	return exdeath_model


# If we don't want to attack, pass
func start_attack():
	exdeath_model.start_attack()


func stop_attack():
	set_idle()


func set_idle():
	exdeath_model.set_idle()


func set_moving():
	exdeath_model.set_moving()
