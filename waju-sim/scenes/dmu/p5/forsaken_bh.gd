extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var fail_list: FailList = get_tree().get_first_node_in_group("fail_list")


func fade_in():
	animation_player.play("fade_in")


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is not PlayableCharacter:
		return
	if body.is_player():
		fail_list.add_fail("Player was hit by Black Hole.")
