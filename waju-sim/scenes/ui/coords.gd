# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Label

@onready var fps_label: Label = %FPSLabel

var player: Player


func _ready() -> void:
	GameEvents.party_ready.connect(on_party_ready)
	if !visible:
		set_process(false)


func _process(_delta: float) -> void:
	if !player:
		return
	var model_rotation: float = rad_to_deg(player.get_model_rotation().y)
	self.text = str("%.2f" % player.position.x, ", ", "%.2f" % player.position.z,
		"\nAngle: %f" % (fposmod((model_rotation + 180), 360)))
	#fps_label.text = str("FPS: ", Engine.get_frames_per_second())
	
	#var small_number := 90
	#var big_number := 360
	#
#
	#var player_rotation := fposmod((rad_to_deg(player.get_model_rotation().y) + 180), 360.0)
	#var target_pos = Vector2.ZERO
	#var angle_to_gaze_target = fposmod(rad_to_deg(v2(player.global_position).angle_to_point(
		#target_pos)) * -1 + 90, 360.0)
	#var looking_at_target := false
	#if angle_to_gaze_target < small_number:
		#if player_rotation < angle_to_gaze_target + small_number or player_rotation > big_number + angle_to_gaze_target:
			#looking_at_target = true
	#elif angle_to_gaze_target > big_number:
		#if player_rotation > angle_to_gaze_target - small_number or player_rotation < angle_to_gaze_target - big_number:
			#looking_at_target = true
	#elif player_rotation > angle_to_gaze_target - small_number and player_rotation < angle_to_gaze_target + small_number:
		#looking_at_target = true
	#fps_label.text = "true" if looking_at_target else "false"


func on_party_ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func _on_visibility_changed() -> void:
	if visible:
		set_process(true)

func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)
