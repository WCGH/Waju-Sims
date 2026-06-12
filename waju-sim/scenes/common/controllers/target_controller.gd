# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name TargetController

signal target_changed(new_target: Node3D)


@onready var party_controller: PartyController = get_tree().get_first_node_in_group("party_controller")
# TODO: adapt to more general usage.

var player: Player
var current_target: Node3D
var valid_targets: Array
var tab_index := 0


func _ready() -> void:
	party_controller.party_ready.connect(on_party_ready)


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("tab"):
		tab_target()


func add_targetable_npc(new_target: Node3D) -> void:
	valid_targets.append(new_target)


func remove_targetable_npc(removed_target: Node3D) -> void:
	valid_targets.erase(removed_target)
	if current_target == removed_target:
		change_target(null)


func tab_target() -> void:
	if valid_targets.size() == 0:
		return
	if !current_target:
		tab_index = 0
	else:
		tab_index += 1
		if tab_index == valid_targets.size():
			tab_index = 0
	if !tab_index < valid_targets.size():
		tab_index = 0
	change_target(valid_targets[tab_index])


func change_target(new_target: Node3D) -> void:
	# Ignore invalid targets
	if !valid_targets.has(new_target):
		new_target = null
	if current_target:
		if current_target == new_target:
			return
		current_target.remove_active_target()
	current_target = new_target
	target_changed.emit(current_target)
	if current_target != null:
		current_target.set_active_target()


func on_party_ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	player.target_changed.connect(on_player_target_changed)


func on_player_target_changed(new_target: Node3D) -> void:
	change_target(new_target)
	
