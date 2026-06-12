# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name ExaflareController

@export var cast_duration := 4.0
@export var exaflare_hit_radius := 12.466
@export var exaflare_spread := 14.79
@export var fire_hit_radius := 16.0
@export var ice_hit_radius := 90.0
@export var exa_marker_duration := 0.4
@export var fire_ice_marker_duration := 0.3

@onready var ground_aoe_controller: GroundAoeController =\
	get_tree().get_first_node_in_group("ground_aoe_controller")
@onready var target_cast_bar: TargetCastBar = get_tree().get_first_node_in_group("target_cast_bar")
@onready var enemy_cast_bar: EnemyCastBar = get_tree().get_first_node_in_group("enemy_cast_bar")
@onready var marker_layer: Node3D = get_tree().get_first_node_in_group("ground_marker_layer")
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var boss: P7Boss
var exa_scene_path := "uid://cy25elexmjwpc"
var start_pos := [Vector3(0, 0, -16), Vector3(13.8564, 0, 8), Vector3(-13.8564, 0, 8)]
var start_y_rotation := [0, 0, -90]
var exaflares := []
var rotation_pattern := [0, 0, 0]
var rotation_deg := 0.0
var is_fire: bool
var exa_scene: PackedScene


func pre_load() -> void:
	ResourceLoader.load_threaded_request(exa_scene_path)
	exa_scene = ResourceLoader.load_threaded_get(exa_scene_path)
	var exaflare: Node3D = exa_scene.instantiate()
	marker_layer.add_child(exaflare)
	exaflare.queue_free()

# 14.2
func spawn_exaflares() -> void:
	boss = get_tree().get_first_node_in_group("p7_boss")
	randomize_pattern()
	# Spawn exaflares.
	
	# DEBUG
	#print("Thread load status: ", ResourceLoader.load_threaded_get_status(exa_scene_path))
	
	#var exa_scene: PackedScene = ResourceLoader.load_threaded_get(exa_scene_path) 
	for i in 3:
		var exaflare: Node3D = exa_scene.instantiate()
		marker_layer.add_child(exaflare)
		exaflare.set_global_position(start_pos[i].rotated(Vector3.UP, deg_to_rad(rotation_deg)))
		exaflare.rotation_degrees.y = start_y_rotation[i] + (rotation_pattern[i] * 45)
		exaflares.append(exaflare)
	# Start cast.
	target_cast_bar.cast("Exaflare's Edge", 6.5, boss)
	enemy_cast_bar.start_cast_bar_1("Exaflare's Edge", 6.5)
	# Start boss animation.
	boss.start_exa_cast()
	# Start animation timer.
	animation_player.play("exaflare")


# Random multiples of 45 deg. 0 = South/Safe, 1 = West, 2 = East.
func randomize_pattern() -> void:
	for i in 3:
		if i == 0:
			rotation_pattern[i] = randi_range(0, 7)
		else:  # Randomize valid position (0, 2, 4, 5, 6).
			rotation_pattern[i] = randi_range(0, 4) * 2
			if rotation_pattern[i] == 8:
				rotation_pattern[i] = 5
	rotation_deg = 120.0 * randi_range(0, 2)
	is_fire = randi() % 2 == 0


# 15.4 (1.2)
func sword_glow() -> void:
	boss.start_wep_glow(is_fire)

# 20.2 (6.0)
func exa_hit_animation() -> void:
	boss.finish_exa_cast()

# 20.6 (6.4)
func exa_fade_out() -> void:
	for exaflare: Node3D in exaflares:
		exaflare.fade_out()


# 20.9 (6.7)
func exa_hit(hit_number: int) -> void:
	# Spawn Fire/Ice AoE
	if hit_number == 1:
		if is_fire:
			ground_aoe_controller.spawn_circle(Vector2.ZERO, fire_hit_radius,
			fire_ice_marker_duration, Color.RED, [0, 0, "Fire of Ascalon"])
		else:
			ground_aoe_controller.spawn_donut(Vector2.ZERO, fire_hit_radius, ice_hit_radius,
			fire_ice_marker_duration, Color.LIGHT_SKY_BLUE, [0, 0, "Ice of Ascalon"])
	# Spawn Exa hit
	for exaflare: Node3D in exaflares:
		# First hit (single hit)
		if hit_number == 1:
			ground_aoe_controller.spawn_circle(v2(exaflare.get_global_position()), exaflare_hit_radius,
				exa_marker_duration, Color.ORANGE_RED, [0, 0, "Exaflare"])
		# Multi-hits (2-5)
		else:
			for rotation: float in [-90, 0, 90]:
				var pos: Vector3 = exaflare.global_position
				var z_basis: Vector3 = exaflare.global_transform.basis.rotated(
					Vector3.UP, deg_to_rad(rotation)).z.normalized()
				var tar: Vector3 = (-z_basis * exaflare_spread * (hit_number - 1)) + pos
				ground_aoe_controller.spawn_circle(v2(tar), exaflare_hit_radius,
				exa_marker_duration, Color.ORANGE_RED, [0, 0, "Exaflare"])
			# Free up exaflare once we're done with it.
			if hit_number == 5:
				exaflare.queue_free()
	# Clean up last hit.
	if hit_number == 5:
		exaflares = []

# 22.8 exa 2 (8.6)
# 24.7 exa 3 (10.5)
# 26.6 exa 4 (12.4)
# 28.5 exa 5 (14.3)

## Utility Methods

# Converts Vector3(x,z) -> Vectors2
func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
