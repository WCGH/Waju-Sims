# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

@export var enabled := false

var next_frame := false
var process_slowmo := false


func _process(_delta: float) -> void:
	if !enabled:
		return
		
	if get_tree().paused == false and next_frame == true:
		get_tree().paused = true
	
	if get_tree().paused == false and process_slowmo == true:
		get_tree().paused = true
		await get_tree().create_timer(1).timeout
		get_tree().paused = false
		
	if get_tree().paused == true and Input.is_action_just_pressed("left_click"):
		next_frame = true
		process_slowmo = false
		get_tree().paused = false
		print("next frame")
	
	if get_tree().paused == true and Input.is_action_just_pressed("right_click"):
		process_slowmo = true
		next_frame = false
		get_tree().paused = false
		print("process_slowmo")
		
	if Input.is_action_just_pressed("MMB"):
		if get_tree().paused == false:
			get_tree().paused = true
			print("process paused")
		elif get_tree().paused == true:
			process_slowmo = false
			next_frame = false
			get_tree().paused = false
			print("process unpaused")
