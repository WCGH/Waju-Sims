extends Node3D


@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]


func play_lounge_idle():
	state_machine.travel("lounge_idle")


func play_fade_out():
	state_machine.travel("fade_out")


func play_run():
	state_machine.travel("run")


func play_lc_dash():
	state_machine.start("limit_cut_dash")
	#state_machine.travel("limit_cut_dash")
