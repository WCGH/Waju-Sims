extends CharacterBody3D

class_name P4Kefka

@onready var animation_player: AnimationPlayer = $KefkaHitboxRing/AnimationPlayer
@onready var kefka_hitbox_ring: Node3D = %KefkaHitboxRing
@onready var kefka_model: Node3D = %KefkaModel
@onready var orb_animation_tree: AnimationTree = $OrbRings/AnimationTree
@onready var state_machine: AnimationNodeStateMachinePlayback = orb_animation_tree["parameters/playback"]
@onready var orb_rings: Node3D = $OrbRings
@onready var thunder_fake_node: Node3D = $OrbRings/ThunderRing/Ring/ThunderFake
@onready var thunder_real_node: Node3D = $OrbRings/ThunderRing/Ring/ThunderReal
@onready var ice_fake_node: Node3D = $OrbRings/IceRing/Ring/IceFake
@onready var ice_real_node: Node3D = $OrbRings/IceRing/Ring/IceReal
@onready var thunder_ring: Node3D = $OrbRings/ThunderRing
@onready var ice_ring: Node3D = $OrbRings/IceRing


func _ready() -> void:
	kefka_model.play_stand_idle()


func set_active_target() -> void:
	animation_player.play("grow_in")


func remove_active_target() -> void:
	kefka_hitbox_ring.hide()


func get_model() -> Node3D:
	return kefka_model


func show_orbs(thunder_fake:bool, ice_fake: bool):
	orb_rings.show()
	thunder_ring.show()
	ice_ring.show()
	thunder_fake_node.visible = thunder_fake
	thunder_real_node.visible = !thunder_fake
	ice_fake_node.visible = ice_fake
	ice_real_node.visible = !ice_fake
	state_machine.travel("grow_in")


func show_thunder_orb(thunder_fake: bool):
	orb_rings.show()
	thunder_ring.show()
	ice_ring.hide()
	thunder_fake_node.visible = thunder_fake
	thunder_real_node.visible = !thunder_fake
	state_machine.travel("grow_in")


func show_ice_orb(ice_fake: bool):
	orb_rings.show()
	ice_ring.show()
	thunder_ring.hide()
	ice_fake_node.visible = ice_fake
	ice_real_node.visible = !ice_fake
	state_machine.travel("grow_in")


# TODO: fade out
func hide_orbs():
	orb_rings.hide()


## If we don't want to attack, pass
#func start_attack():
	#kefka_model.start_attack()

#
#func stop_attack():
	#set_idle()

#
#func set_idle():
	#kefka_model.set_idle()
#
#
#func set_moving():
	#kefka_model.set_moving()
