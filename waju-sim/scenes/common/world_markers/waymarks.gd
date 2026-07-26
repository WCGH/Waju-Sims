# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

class_name Waymarks

const WAYMARK_HEIGHT = 0.0
const HIDE_VECTOR := Vector2(999, 999)

@onready var waymarks := {
	"wm_a": %WM_A, "wm_b": %WM_B, "wm_c": %WM_C, "wm_d": %WM_D,
	"wm_1": %WM_1, "wm_2": %WM_2, "wm_3": %WM_3, "wm_4": %WM_4
}
var active_wm_positions: Dictionary


func _ready() -> void:
	update_waymarks()


func update_waymarks() -> void:
	if active_wm_positions.is_empty():
		return
	for key in active_wm_positions:
		if active_wm_positions[key] is String:
			continue
		if active_wm_positions[key] == HIDE_VECTOR:
			hide_wm(key)
			continue
		move_waymark(key, active_wm_positions[key])


func get_active_wm_positions():
	return active_wm_positions


func set_waymarks(new_waymarks: Dictionary):
	active_wm_positions = new_waymarks
	if !waymarks.is_empty():
		update_waymarks()


func move_waymark(wm_key: String, pos: Vector2):
	active_wm_positions[wm_key] = pos
	save_current_waymarks()
	waymarks[wm_key].global_position = Vector3(pos.x, WAYMARK_HEIGHT, pos.y)
	waymarks[wm_key].visible = true


func hide_wm(wm_key: String):
	active_wm_positions[wm_key] = HIDE_VECTOR
	save_current_waymarks()
	waymarks[wm_key].visible = false


func hide_all():
	for key in waymarks:
		active_wm_positions[key] = HIDE_VECTOR
		waymarks[key].visible = false
	save_current_waymarks()


func save_current_waymarks() -> void:
	Global.set_encounter_waymarks(active_wm_positions)
	
