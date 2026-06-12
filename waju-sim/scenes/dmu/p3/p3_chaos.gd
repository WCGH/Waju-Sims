# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MoveableBoss

@onready var animation_player: AnimationPlayer = $ChaosHitboxRing/AnimationPlayer
@onready var chaos_hitbox_ring: Node3D = %ChaosHitboxRing
@onready var chaos_model: Node3D = %ChaosModel




func set_active_target() -> void:
	animation_player.play("grow_in")


func remove_active_target() -> void:
	chaos_hitbox_ring.hide()


func get_model() -> Node3D:
	return chaos_model


# If we don't want to attack, pass
func start_attack():
	chaos_model.start_attack()


func stop_attack():
	set_idle()


func set_idle():
	chaos_model.set_idle()


func set_moving():
	chaos_model.set_moving()
