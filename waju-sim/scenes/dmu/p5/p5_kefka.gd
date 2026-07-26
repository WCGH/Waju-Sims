extends CharacterBody3D

class_name P5Kefka

@onready var animation_player: AnimationPlayer = $KefkaHitboxRing/AnimationPlayer
@onready var kefka_hitbox_ring: Node3D = %KefkaHitboxRing
@onready var kefka_model: Node3D = %KefkaModel


func _ready() -> void:
	kefka_model.play_stand_idle()


func set_active_target() -> void:
	animation_player.play("grow_in")


func remove_active_target() -> void:
	kefka_hitbox_ring.hide()


func get_model() -> Node3D:
	return kefka_model


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
