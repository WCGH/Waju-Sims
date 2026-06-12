extends Node3D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func play_idle():
	state_machine.travel("idle")


func play_raise_left():
	state_machine.travel("raise_left")


func play_left_smash():
	state_machine.travel("left_smash")


func play_raise_right():
	state_machine.travel("raise_right")


func play_right_smash():
	state_machine.travel("right_smash")


func play_body_slam():
	state_machine.travel("body_slam")


func play_float_idle():
	state_machine.travel("float_idle")


func play_stomp():
	state_machine.travel("stomp")
