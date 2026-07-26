# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Enemy
class_name Darkscale

@onready var divebomb_animation: AnimationPlayer = $DivebombAnimation


func play_divebomb() -> void:
	divebomb_animation.play("cbbm_hide_sp01_Armature")


func _on_divebomb_animation_animation_finished(_anim_name: String) -> void:
	visible = false


# Used in conjunction with divebomb animation
func move_toward_center() -> void:
	var tween := get_tree().create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.tween_property(self, "global_position", Vector3(0, global_position.y, 0), 1.5)
