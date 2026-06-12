# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name P6Sequence

signal phase_finished(party: Dictionary)

var debug := false

# Common P6 spell dimensions
const WYRM_DONUT_INNER_RADIUS = 41.25
const WYRM_DONUT_OUTER_RADIUS = 65.0
const TETHER_MIN_LENGTH = 52.7
const WYRM_CONE_ANGLE = 25.21
const WYRM_CONE_LENGHT = 100.0 
const WYRM_TB_CONE_ANGLE = 55.0
const WYRM_TB_CONE_LENGTH = 100.0
const WYRM_TB_SOLO_AOE_RADIUS = 32.0
const WYRM_TB_SHARED_AOE_RADIUS = 15.0
const VOW_RADIUS := 10.0
const AA_RADIUS := 17.0
const WINGS_TB_RADIUS := 21.0
const DIVEBOMB_WIDTH := 45
const DIVEBOMB_LENGTH := 147.0
const HOT_WING_WIDTH = 37.8
const HOT_WING_LENGTH = 100.0
const HOT_TAIL_WIDTH = 33.75
const HOT_TAIL_LENGTH = 100.0
const WING_TAIL_TELE_DURATION = 0.5
const ATONEMENT_DURATION = 100.0
const VOW_DURATION = 34.0

# Resource file paths
static var nid_path := "uid://2gx8n4cahjp6"
static var hra_path := "uid://dvv4qrwlylix"
static var vow_icon_path := "uid://bd3so8mgkmg2i"
static var atonement_icon_path := "uid://75oxu6ts7kjp"

# Controllers
@onready var target_controller: TargetController = %TargetController
@onready var tether_controller: TetherController = %TetherController
@onready var ground_aoe_controller: GroundAoeController = %GroundAoEController
# UI Elements
@onready var target_cast_bar : TargetCastBar = %TargetCastBar
@onready var enemy_cast_bar : EnemyCastBar = %EnemyCastBar
@onready var fail_list : FailList = %FailList
@onready var enemies_layer: Node3D = get_tree().get_first_node_in_group("enemies_layer")
# Common NPC positions
@onready var npc_positions := P6_NPC_Positions.npc_positions
@onready var test_timer: Timer = %testTimer

@onready var sequences := {"wyrm1" : %Wyrm1, "aa1" : %AA1, "wings1" : %Wings1,
	"wroth": %Wroth, "aa2": %AA2, "wings2": %Wings2, "wyrm2": %Wyrm2}
static var starting_points := ["wyrm1", "wings1", "wroth", "wings2" , "wyrm2"]
static var atonement_time_remain := {"wroth": 99, "wings2": 53, "wyrm2": 31}
static var starting_point_index: int
static var vow_icon_scene: PackedScene
static var atonement_icon_scene: PackedScene

# Units
static var party : Dictionary
static var player : Player
static var vow_target: PlayableCharacter
static var nid: P6Boss
static var hra: P6Boss


# Handles threaded pre-loading of all assets used this phase.
func _ready() -> void:
	if debug:
		print("P6 Sequence on ready called.")
		print("Selected Role: ", Global.ROLE_KEYS[Global.selected_role_index])
	ResourceLoader.load_threaded_request(nid_path, "PackedScene")
	ResourceLoader.load_threaded_request(hra_path, "PackedScene")
	ResourceLoader.load_threaded_request(vow_icon_path, "PackedScene")
	atonement_icon_scene = ResourceLoader.load(atonement_icon_path, "PackedScene")
	tether_controller.preload_resources()
	ground_aoe_controller.preload_aoe(["line", "circle", "cone", "donut"])


# Called from EncounterController when we're ready to go.
func start_sequence(new_party: Dictionary) -> Signal:
	starting_point_index = DsrGlobal.p6_selected_seq
	assert(starting_point_index < starting_points.size(),
		"Error. Selected sequence out of range.")
	assert(sequences.has(starting_points[starting_point_index]),
		"Error. Sequence key mismatch in P6Sequence.")
	party = new_party
	player = get_tree().get_first_node_in_group("player")
	# Assign shared assignments
	assign_vow()
	# Spawn in assets when loaded
	await get_tree().create_timer(2.0).timeout
	spawn_bosses()
	# Start selected sequence
	sequences[starting_points[starting_point_index]].start_sub_sequence()
	return phase_finished


func play_sequence(sequence_key: String) -> void:
	assert(sequences.has(sequence_key),
		"Error. Sequence key mismatch in P6Sequence.")
	sequences[sequence_key].start_sub_sequence()


func assign_vow() -> void:
	var party_list := party.values()
	var first_vow: int = DsrSavedVariables.get_data("p6", "first_vow")
	# Determined vow target.
	if first_vow != DsrSavedVariables.first_vow.RANDOM:
		vow_target = party_list[first_vow + 3]
	# Random vow target.
	else:
		var dps_party_list := party_list.slice(4, 8)
		randomize()
		vow_target = dps_party_list.pick_random()
	# If we're starting passed first vow or attonement, assign them.
	if starting_point_index > 0:
		spawn_vow()
		if starting_point_index > 1:
			spawn_atonement()


func spawn_vow() -> void:
	vow_icon_scene = ResourceLoader.load_threaded_get(vow_icon_path)
	# Wings 1. Vow on first target. 10s delta.
	if starting_point_index == 1:
		vow_target.add_debuff(vow_icon_scene, VOW_DURATION - 10)
	# Wroth. Vow on T1.
	elif starting_point_index == 2:
		party["t1"].add_debuff(vow_icon_scene, VOW_DURATION)
	# Wings2. Vow on T2. 15s delta.
	elif starting_point_index == 3:
		party["t2"].add_debuff(vow_icon_scene, VOW_DURATION - 12)
	# Wyrm 2. Vow on Melee.
	elif starting_point_index == 4:
		if vow_target == party["m1"]:
			party["m2"].add_debuff(vow_icon_scene, VOW_DURATION)
		else:
			party["m1"].add_debuff(vow_icon_scene, VOW_DURATION)


func spawn_atonement() -> void:
	vow_target.add_debuff(atonement_icon_scene,
	atonement_time_remain[starting_points[starting_point_index]])


func spawn_bosses() -> void:
	if !vow_icon_scene:
		vow_icon_scene = ResourceLoader.load_threaded_get(vow_icon_path)
	var nid_scene: PackedScene = ResourceLoader.load_threaded_get(nid_path)
	var hra_scene: PackedScene = ResourceLoader.load_threaded_get(hra_path)
	nid = nid_scene.instantiate()
	hra = hra_scene.instantiate()
	nid.rotation_degrees.y = 90
	hra.rotation_degrees.y = -90
	enemies_layer.add_child(nid)
	enemies_layer.add_child(hra)
	nid.move_to(npc_positions["nid_spawn"])
	hra.move_to(npc_positions["hra_spawn"])
	target_controller.add_targetable_npc(nid)
	target_controller.add_targetable_npc(hra)


## Common Utility Functions


# Converts Vector3(x,z) -> Vectors2
func v2(v3: Vector3) -> Vector2:
	return Vector2(v3.x, v3.z)


# Inverted 180 to correct P6 boss facing "backwards".
func look_at_v2(unit: Node3D, target: Vector2) -> void:
	unit.look_at(Vector3(target.x, 0, target.y))
	unit.rotate_y(deg_to_rad(180))


func get_two_nearest_players_to_vector(vec2 : Vector2) -> Array:
	var nearest := ""
	var second_nearest := ""
	var nearest_dist_sqrd := 0.0
	var second_nearest_dist_sqrd := 0.0
	for key: String in party:
		var pc: PlayableCharacter = party[key]
		var dist := v2(pc.global_position).distance_squared_to(vec2)
		if nearest_dist_sqrd == 0.0 or dist < nearest_dist_sqrd:
			second_nearest = nearest
			second_nearest_dist_sqrd = nearest_dist_sqrd
			nearest = key
			nearest_dist_sqrd = dist
		elif second_nearest_dist_sqrd == 0.0 or dist < second_nearest_dist_sqrd:
			second_nearest = key
			second_nearest_dist_sqrd = dist
	return [nearest, second_nearest]


func get_two_farthest_players_from_vector(vec2 : Vector2) -> Array:
	var farthest := ""
	var second_farthest := ""
	var farthest_dist_sqrd := 0.0
	var second_farthest_dist_sqrd := 0.0
	for key: String in party:
		var pc: PlayableCharacter = party[key]
		var dist := v2(pc.global_position).distance_squared_to(vec2)
		if dist > farthest_dist_sqrd:
			second_farthest = farthest
			second_farthest_dist_sqrd = farthest_dist_sqrd
			farthest = key
			farthest_dist_sqrd = dist
		elif  dist > second_farthest_dist_sqrd:
			second_farthest = key
			second_farthest_dist_sqrd = dist
	return [farthest, second_farthest]
