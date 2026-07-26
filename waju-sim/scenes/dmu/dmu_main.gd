# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## DMU Main

extends Node

const WINDOW_TITLE := "DMU Sim"

var seq_scene_paths := {
	0: "uid://cwyllh1xj6q5a", #P2 Forsaken
	1: "uid://bcoqkgenftan6", #P3
	2: "uid://cxro2gan53o1k", #P4
	3: "uid://bilj5u4ew64sp", #P5
}


func _ready() -> void:
	Global.set_encounter(Global.Encounter.DMU)
	if get_node("/root/DmuSession").is_server_mode():
		call_deferred("_open_server_scene")
		return
	get_window().set_title(WINDOW_TITLE)
	call_deferred("_open_session_menu")


func _open_server_scene() -> void:
	get_tree().change_scene_to_file("res://scenes/dmu/multiplayer/dmu_server.tscn")


func _open_session_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/dmu/multiplayer/dmu_session_menu.tscn")
