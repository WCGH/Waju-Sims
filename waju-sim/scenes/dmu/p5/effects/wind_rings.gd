extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_ring_anim():
	animation_player.play("ring_animation")
