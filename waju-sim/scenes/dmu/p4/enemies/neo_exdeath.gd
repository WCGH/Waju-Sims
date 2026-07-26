extends Node3D

class_name NeoExdeath

const EAST_POS := Vector3(17.0, 6.5, 5.0)
const WEST_POS := Vector3(-17.0, 6.5, 5.0)

@onready var animation_tree: AnimationTree = $AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = animation_tree["parameters/playback"]
@onready var real_ring: MeshInstance3D = $OrbRings/RealRing
@onready var fake_ring: MeshInstance3D = $OrbRings/FakeRing
@onready var ring_animation_player: AnimationPlayer = $OrbRings/AnimationPlayer
@onready var black_antilight: MeshInstance3D = %BlackAntilight
@onready var white_antilight: MeshInstance3D = %WhiteAntilight


func play_idle():
	state_machine.travel("idle")


func play_fade_in():
	state_machine.travel("fade_in")


func play_fade_out():
	state_machine.travel("fade_out")


func play_gc_cast():
	state_machine.travel("gc_cast")


func play_gc_finish():
	state_machine.travel("gc_finish")


func show_antilight(black_west: bool):
	black_antilight.show()
	white_antilight.show()
	if black_west:
		black_antilight.position = WEST_POS
		white_antilight.position = EAST_POS


func hide_antilight():
	black_antilight.hide()
	white_antilight.hide()


# TODO: fade in/out
func show_orbs(neo_fake: bool):
	real_ring.visible = !neo_fake
	fake_ring.visible = neo_fake


func hide_orbs():
	real_ring.hide()
	fake_ring.hide()
