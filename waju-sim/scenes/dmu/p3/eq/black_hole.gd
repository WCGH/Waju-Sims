extends Node3D

class_name BlackHole


@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_fade_in():
	animation_player.play("fade_in")


func play_fade_out():
	animation_player.play("fade_out")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not PlayableCharacter:
		return
	GameEvents.emit_bh_body_entered(body)
