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
	2: "uid://", 
	3: "uid://", 
	4: "uid://", 
	5: "uid://" 
}


func _ready() -> void:
	Global.set_encounter(Global.Encounter.DMU)
	get_window().set_title(WINDOW_TITLE)
	var selected_seq: int = DmuSavedVariables.get_data("settings", "selected_seq")
	var loaded_scene = load(seq_scene_paths[selected_seq])
	await get_tree().process_frame
	get_tree().change_scene_to_packed(loaded_scene)
