# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name WrothFlameController

const WROTH_LINE_WIDTH = 37.8
const WROTH_LINE_LENGTH = 200.0
const WROTH_TELEGRAPH_TIME = 1.4

@export var wroth_line_scene: PackedScene
@export var wroth_zig_scene: PackedScene

@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
@onready var ground_markers : Node3D = get_tree().get_first_node_in_group("ground_marker_layer")

# Defaul position is second orb South
var flame_positions: Array[Vector2] = [Vector2(0, 0), Vector2(-27, 27), Vector2(27, -27)]

var flames: Array[Node3D]


func instantiate_orbs(south_orb: bool) -> void:
	var flames_rotation := deg_to_rad(randi_range(0, 1) * -90.0)
	if !south_orb:
		flames_rotation += deg_to_rad(180)
	# Instantiate orbs
	for i in 3:
		if randi() % 2 == 0:
			flames.append(wroth_line_scene.instantiate())
		else:
			flames.append(wroth_zig_scene.instantiate())
		ground_markers.add_child(flames[i])
		# Randomize orientation
		flames[i].rotate_y(deg_to_rad(randi_range(0, 1) * 90.0))
		# Move to position
		var v2_pos: Vector2 = flame_positions[i].rotated(flames_rotation)
		flames[i].global_position = Vector3(v2_pos.x, 0, v2_pos.y)
		flames[i].visible = false


func show_orbs(orb_index: int) -> void:
	flames[orb_index].grow_in()


func hide_orbs(orb_index: int) -> void:
	flames[orb_index].shrink_out()


# TODO: Improve visual (i.e. cross aoe overlap).
func spawn_orb_telegraph(orb_index: int) -> void:
	var cross_target_1 := v2(flames[orb_index].global_position + Vector3(WROTH_LINE_LENGTH / 2, 0, 0))
	var cross_target_2 := v2(flames[orb_index].global_position + Vector3(0, 0, WROTH_LINE_LENGTH / 2))
	ground_aoe_controller.spawn_line(cross_target_1, WROTH_LINE_WIDTH, WROTH_LINE_LENGTH,
		v2(flames[orb_index].global_position), WROTH_TELEGRAPH_TIME, Color.CORAL, [0, 0, "Wroth Flames"], true)
	ground_aoe_controller.spawn_line(cross_target_2, WROTH_LINE_WIDTH, WROTH_LINE_LENGTH,
		v2(flames[orb_index].global_position), WROTH_TELEGRAPH_TIME, Color.CORAL, [0, 0, "Wroth Flames"], true)


func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)
