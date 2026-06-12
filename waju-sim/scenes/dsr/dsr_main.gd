# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## DSR Main

extends Node

const WINDOW_TITLE := "DSR Sim"

var seq_scene_paths := {
	0: "uid://dstsy0m2vg2yg", #p3_lc
	1: "uid://cyu18grwir0wr", #p5_wrath
	2: "uid://6o4rt65mendi", #p5_death
	3: "uid://d1yi4mckax1sd", #p6
	4: "uid://du4axe5tk7sgp", #p7
}


func _ready() -> void:
	Global.set_encounter(Global.Encounter.DSR)
	get_window().set_title(WINDOW_TITLE)
	var selected_seq: int = SavedVariables.get_encounter_data("settings", "selected_seq")
	var loaded_scene = load(seq_scene_paths[selected_seq])
	await get_tree().process_frame
	get_tree().change_scene_to_packed(loaded_scene)
