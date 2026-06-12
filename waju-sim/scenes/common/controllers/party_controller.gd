# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Party Controller
## Creates party of 7 bots and 1 player, as an array of CB3Ds
class_name PartyController
extends Node

signal party_ready

const SPAWN_POSITIONS = {"t1": Vector3(0, 1, -5), "t2": Vector3(0, 1, 5),
	"h1": Vector3(-5, 1, 0), "h2": Vector3(5, 1, 0),
	"m1": Vector3(-5, 1, 5), "m2": Vector3(5, 1, 5),
	"r1": Vector3(-5, 1, -5), "r2": Vector3(5, 1, -5)}

@export var player_scene : PackedScene
@export var bot_scene : PackedScene
@export var tank_1_model: PackedScene
@export var tank_2_model: PackedScene
@export var healer_1_model: PackedScene
@export var healer_2_model: PackedScene
@export var melee_1_model: PackedScene
@export var melee_2_model: PackedScene
@export var ranged_model: PackedScene
@export var caster_model: PackedScene

var party : Dictionary
var role_keys := Global.ROLE_KEYS
var existing_party := false

@onready var party_list : PartyList = get_tree().get_first_node_in_group("party_list")
@onready var characters_spawn_node : Node = get_tree().get_first_node_in_group("characters_layer")
@onready var models := {"t1": tank_1_model, "t2": tank_2_model,
	"h1": healer_1_model, "h2": healer_2_model,
	"m1": melee_1_model, "m2": melee_2_model,
	"r1": ranged_model, "r2": caster_model}


func instantiate_party(player_role : String) -> Dictionary:
	if existing_party:
		clear_party()
	for key : String in role_keys:
		if key == player_role:
			instantiate_player(key)
			Global.player_role_key = key
		else:
			instantiate_bot(key)
	party_list.create_party_list(player_role)
	# TODO: find signal usages and clean up/consolidate
	party_ready.emit()
	GameEvents.emit_party_ready()
	GameEvents.toggle_focus.connect(on_toggle_focus)
	if Global.current_focus_key != "":
		on_toggle_focus(Global.current_focus_key)
	existing_party = true
	return party


func clear_party() -> void:
	party_list.clear_party()
	for pc: CharacterBody3D in characters_spawn_node.get_children():
		characters_spawn_node.remove_child(pc)
		pc.queue_free()


func instantiate_player(role_key : String) -> Dictionary:
	#print("Spawning player with role: ", Global.ROLE_NAMES[role_key])
	var player : Node3D = player_scene.instantiate()
	player.set_parameters(role_key, models[role_key], SPAWN_POSITIONS[role_key])
	characters_spawn_node.add_child(player)
	player.set_role_icon()
	party[role_key] = player
	return {role_key: player}


func instantiate_bot(role_key : String) -> void:
	#print("Spawning bot with role: ", Global.ROLE_NAMES[role_key])
	var bot : Node3D = bot_scene.instantiate()
	bot.set_parameters(role_key, models[role_key], SPAWN_POSITIONS[role_key])
	characters_spawn_node.add_child(bot)
	bot.set_role_icon()
	party[role_key] = bot


func on_toggle_focus(role_key: String):
	for key in party:
		party[key].set_focus_visible(key == role_key)
