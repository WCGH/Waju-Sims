extends CharacterBody3D

class_name P4Chaos

@onready var chaos_model: Node3D = %ChaosModel
@onready var real_ring: MeshInstance3D = $OrbRings/RealRing
@onready var fake_ring: MeshInstance3D = $OrbRings/FakeRing


func get_model() -> Node3D:
	return chaos_model


# TODO: fade in/out
func show_orbs(chaos_fake: bool):
	real_ring.visible = !chaos_fake
	fake_ring.visible = chaos_fake


func hide_orbs():
	real_ring.hide()
	fake_ring.hide()
