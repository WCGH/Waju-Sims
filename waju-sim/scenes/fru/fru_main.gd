# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## FRU Main

extends Node

const WINDOW_TITLE := "FRU Sim"

var seq_scene_paths := {
	0: "uid://ds3wx4lmthkq0", #p2_lr
	1: "uid://d3i10nfsr3ych", #p3_ur
	2: "uid://050gfu5rnkwe", #p3_apoc
	3: "uid://72xsy2riqeef", #p4_dd
	4: "uid://hg8cllrtgwu6", #p4_ct
	5: "uid://dn43lysx7adqc" #p5
}


func _ready() -> void:
	Global.set_encounter(Global.Encounter.FRU)
	get_window().set_title(WINDOW_TITLE)
	var selected_seq: int = FruSavedVariables.get_data("settings", "selected_seq")
	var loaded_scene = load(seq_scene_paths[selected_seq])
	await get_tree().process_frame
	get_tree().change_scene_to_packed(loaded_scene)
