extends Node3D

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	animation_tree.animation_finished.connect(on_animation_finished)


func cast_1_start():
	state_machine.travel("cast_1_start")


func cast_1_finish():
	state_machine.travel("cast_1_finish")


func cast_charge():
	state_machine.travel("charge")


func cast_kick():
	state_machine.travel("kick")


func jump_and_hide():
	state_machine.travel("jump")


func on_animation_finished(anim_name: String):
	if anim_name == "cbbm_sp22_up":
		self.hide()
