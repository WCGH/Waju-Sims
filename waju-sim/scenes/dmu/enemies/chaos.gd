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
	state_machine.travel("generic_finish")


func start_lat_long():
	state_machine.travel("latlong_cast")


func finish_lat_long():
	state_machine.travel("lat_long_finish")


func finish_long_lat():
	state_machine.travel("long_lat_finish")


func cast_jump():
	state_machine.travel("jump")
	
