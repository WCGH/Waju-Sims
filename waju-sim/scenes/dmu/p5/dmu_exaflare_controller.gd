extends Node

class_name DMUExaflareController


@onready var exaflare_sequence_anim: AnimationPlayer = $ExaflareSequenceAnim
@onready var special_markers: Node3D = %SpecialMarkers

var exaflare_scene: PackedScene
var intercards := ["nw", "ne"]
var set_positions := {"nw": [0, 1, 2], "ne": [0, 1, 2]}


func preload_resources():
	ResourceLoader.load_threaded_request("uid://c8svu54bng0tk")


func start_exaflares():
	if !exaflare_scene:
		exaflare_scene = ResourceLoader.load_threaded_get("uid://c8svu54bng0tk")
	intercards.shuffle()
	set_positions["ne"].shuffle()
	set_positions["nw"].shuffle()
	exaflare_sequence_anim.play("exaflare_sequence")


func spawn_exa_set(set_index: int):
	var intercard: String = intercards[set_index % 2]
	var set_pos_index
	if set_index % 2 == 0:
		set_pos_index = set_positions[intercard][set_index / 2]
	else:
		set_pos_index = set_positions[intercard][(set_index - 1) / 2]
	var exaflare_left: DmuExaflare = exaflare_scene.instantiate()
	var exaflare_right: DmuExaflare = exaflare_scene.instantiate() 
	special_markers.add_child(exaflare_left)
	special_markers.add_child(exaflare_right)
	exaflare_left.initiate_exaflare(intercard, set_pos_index, "left")
	exaflare_right.initiate_exaflare(intercard, set_pos_index, "right")



## Notes

# 37.5 set 1
# 40 set 2
# 42.5 set 3
# 45.0 set 4
# 47.5 set 5
# 50.0 set 6
