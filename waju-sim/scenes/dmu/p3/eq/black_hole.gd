extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer


func play_fade_in():
	animation_player.play("fade_in")


func play_fade_out():
	animation_player.play("fade_out")
