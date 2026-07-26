# Copyright 2026
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
#class_name PuddleControllerDSR

signal lh_dropped
signal ap_dropped

const LH_RADIUS := 10.0
const AP_RADIUS := 15.0
const LH_DURATION := 10.0
const AP_DURATION := 4.0

@export var circle_aoe_scene : PackedScene

@onready var marker_layer : Node3D = get_tree().get_first_node_in_group("ground_marker_layer")
@onready var altar_pyre_seq : AnimationPlayer = %AltarPyreSeq
@onready var liquid_hell_seq : AnimationPlayer = %LiquidHellSeq

var ap_target : CharacterBody3D
var lh_target : CharacterBody3D
var lh_targets := 3
var ap_count := 0
var lh_count := 0
var lh_positions := [
	Vector2(6.5, 37.6),
	Vector2(4, 28.5),
	Vector2(2.2, 20.1),
	Vector2(0, 12.8)
	]
var ap_positions := [
	Vector2(0, -37.8),
	Vector2(0, -29.6),
	Vector2(0, -22.0)
]


func start_ap_lh_seq(new_ap_target: PlayableCharacter,
	new_lh_target: PlayableCharacter, rotation: float) -> void:
	if new_lh_target.is_player():
		lh_targets = 1
	rotate_positions(rotation)
	ap_target = new_ap_target
	lh_target = new_lh_target
	ap_count = 0
	lh_count = 0
	altar_pyre_seq.play("altar_pyre_seq")
	liquid_hell_seq.play("liquid_hell_seq")


func lh_drop() -> void:
	spawn_lh()
	if lh_count == 4:
		# Wrath sequence will handle last movement based on Grin position
		lh_dropped.emit()
	else:
		lh_target.move_to(lh_positions[lh_count])
		lh_count += 1


func ap_drop() -> void:
	spawn_ap()
	if ap_count == 3:
		# Wrath sequence will handle last movement based on Grin position
		ap_dropped.emit()
	else:
		ap_target.move_to(ap_positions[ap_count])
		ap_count += 1


func spawn_lh() -> void:
	spawn_circle(v2(lh_target.global_position), LH_RADIUS, LH_DURATION,
	 Color.ORANGE_RED, [0, lh_targets, "Liquid Hell", [lh_target]], false)


# TODO: add proper eruption delay to fail/collision check
func spawn_ap() -> void:
	spawn_circle(v2(ap_target.global_position), AP_RADIUS, AP_DURATION,
	 Color.ORANGE_RED, [0, 0, "Altar Pyre", [ap_target]], true)


func spawn_circle(position: Vector2, radius: float, lifetime: float,
	color: Color, fail_conditions: Array, is_ap: bool) -> CircleAoe:
	var new_circle: CircleAoe = circle_aoe_scene.instantiate()
	marker_layer.add_child(new_circle)
	new_circle.set_parameters(Vector3(position.x, 0, position.y), radius, lifetime, color, fail_conditions)
	#new_circle.play_start_animation()
	if is_ap:
		new_circle.check_at_end()
	else:
		new_circle.await_collision()
	return new_circle

func rotate_positions(rotation: float) -> void:
	if rotation == 0.0:
		return
	for i in lh_positions.size():
		lh_positions[i] = rotate_pos(lh_positions[i], rotation)
	for i in ap_positions.size():
		ap_positions[i] = rotate_pos(ap_positions[i], rotation)


# Rotates the vector by a multiple of 90 deg
func rotate_pos(pos : Vector2, rotation: float) -> Vector2:
	return pos.rotated(deg_to_rad(rotation))


func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
