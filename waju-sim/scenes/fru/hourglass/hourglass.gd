# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# Handles all Hourglass animations, as well as the multifire line AoE's from the lasers.

extends Node3D

class_name Hourglass

const LASER_WIDTH := 8
const LASER_LENGTH := 100
const LASER_DURATION := 0.3
const LASER_COLOR := Color.ORANGE
const LASER_HITS := 10
const LASER_ROTATION_DELTA := 15.0   # Angle increment after each laser shot.
const FIRST_DELAY := 2.1   # First delay is a little longer to give player time to move out.
const REPEAT_DELAY := 1.0

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var ground_aoe_controller: GroundAoeController = get_tree().get_first_node_in_group("ground_aoe_controller")
@onready var timer: Timer = $Timer

var relative_snapshot  # Laser target's snapshot position relative to the laser's global_position
var laser_rotation := 0.0
var hourglass_position: Vector2
var rotate_delta: float

# Rotation: 0=cw, 1=ccw
func fire_laser(targets_array: Array, rotate_direction: int) -> void:
	rotate_delta = LASER_ROTATION_DELTA if rotate_direction == 0 else LASER_ROTATION_DELTA * -1.0
	var target: PlayableCharacter = get_nearest_target(targets_array)
	if !ground_aoe_controller:
		ground_aoe_controller = get_tree().get_first_node_in_group("ground_aoe_controller")
	# Fire initial laser hit
	hourglass_position = v2(self.global_position)
	relative_snapshot = v2(target.global_position) - hourglass_position
	ground_aoe_controller.spawn_line(hourglass_position, LASER_WIDTH, LASER_LENGTH,
		(relative_snapshot + hourglass_position), LASER_DURATION, LASER_COLOR,
		[1, 1, "Sinbound Meltdown (Laser)", [target]])
	timer.start(FIRST_DELAY)


func get_nearest_target(targets_array: Array) -> PlayableCharacter:
	var min_dist := 99999.0
	var nearest: PlayableCharacter
	for target in targets_array:
		var dist_sq_to = self.global_position.distance_squared_to(target.global_position)
		if dist_sq_to < min_dist:
			min_dist = dist_sq_to
			nearest = target
	return nearest
	


func _on_timer_timeout() -> void:
	laser_rotation += rotate_delta
	if abs(laser_rotation) < LASER_ROTATION_DELTA * LASER_HITS:
		# Fire laser
		ground_aoe_controller.spawn_line(v2(self.global_position), LASER_WIDTH, LASER_LENGTH,
			(relative_snapshot.rotated(deg_to_rad(laser_rotation)) + v2(self.global_position)),
			LASER_DURATION, LASER_COLOR, [0, 0, "Sinbound Meltdown (Laser)"])
		# Restart timer
		timer.start(REPEAT_DELAY)


func play_rotate_ccw() -> void:
	animation_player.play("ccw_rotate_tele")


func play_rotate_cw() -> void:
	animation_player.play("cw_rotate_tele")


func show_hourglass() -> void:
	animation_player.play("fade_in")


func hide_hourglass() -> void:
	animation_player.play("fade_out")


func show_purple_tether() -> void:
	animation_player.play("grow_in_purple_tether")


func show_yellow_tether() -> void:
	animation_player.play("grow_in_yellow_tether")


func hide_tether() -> void:
	animation_player.play("fade_out_tethers")


func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
