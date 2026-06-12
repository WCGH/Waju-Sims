extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]




func set_idle():
	state_machine.travel("idle")


func set_moving():
	state_machine.travel("walk")


func start_attack():
	state_machine.travel("attack")


func cast_generic():
	state_machine.travel("generic_cast")


func cast_slash():
	state_machine.travel("slash")
