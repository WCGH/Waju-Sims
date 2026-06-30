extends Node3D

class_name DmuExaflare

const AOE_RADIUS := 14.0
const AOE_LIFETIME := 0.6
const AOE_COLOR := Color(0.936, 0.7, 0.07, 0.717)

const STARTING_POSITIONS := {
	"nw": {
		0: {"left": Vector3(-70.711, 0, -14.142), "right": Vector3(-36.77, 0,  -48.083)},
		1: {"left": Vector3(-59.397, 0,  -25.456), "right": Vector3(-25.456, 0,  -59.397)},
		2: {"left": Vector3(-48.083, 0,  -36.77), "right": Vector3(-14.142, 0,  -70.711)},
	},
	"ne": {
		0: {"left": Vector3(14.142, 0,  -70.711), "right": Vector3(48.083, 0,  -36.77)},
		1: {"left": Vector3(25.456, 0,  -59.397), "right": Vector3(59.397, 0,  -25.456)},
		2: {"left": Vector3(36.77, 0,  -48.083), "right": Vector3(70.711, 0,  -14.142)},
	}
}
const ROTATION_DEG := {"nw": Vector3(0, 45.0, 0), "ne": Vector3(0, -45.0, 0)}
const INCREMENT_VECTOR := {"nw": Vector3(11.785, 0, 11.785), "ne": Vector3(-11.785, 0, 11.785)}

@onready var exa_animation_player: AnimationPlayer = $AnimationPlayer
@onready var arrow_animation_player: AnimationPlayer = %ArrowAnimationPlayer
@onready var gac: GroundAoeController = get_tree().get_first_node_in_group("ground_aoe_controller")
@onready var arrow: Node3D = $Arrow

var _start_pos: Vector3
var _increment_vec: Vector3
var blacklist: Array
var player: PlayableCharacter


func initiate_exaflare(intercard: String, set_index: int, side: String):
	_start_pos = STARTING_POSITIONS[intercard][set_index][side]
	_increment_vec = INCREMENT_VECTOR[intercard]
	self.rotation_degrees = ROTATION_DEG[intercard]
	self.global_position = _start_pos
	exa_animation_player.play("fade_in")
	#exa_animation_player.animation_finished.connect(on_animation_finished)
	player = get_tree().get_first_node_in_group("player")
	blacklist = [] if Global.spectate_mode else [player]

func on_animation_finished(anim_name: String):
	if anim_name == "exaflare_timeline":
		self.queue_free()
	if anim_name != "fade_in":
		return
	arrow.show()
	arrow_animation_player.play("arrow_pulse")
	exa_animation_player.play("exaflare_timeline")


func exa_hit(hit_index: int):
	if hit_index == 0:
		arrow_animation_player.stop()
		self.hide()
	gac.spawn_circle(v2(_start_pos + (_increment_vec * hit_index)), AOE_RADIUS,
		AOE_LIFETIME, AOE_COLOR, [0, 8, "Exaflare", [], blacklist])


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)
	





## --NOTES--

# 50.0 tele
# 54.5 hit 1
# 55.1 hit 2 6
# 55.6 hit 3 5
# 56.1 hit 4 5
# 56.6 hit 5 5
# 57.2 hit 6 6
# 57.7 hit 7 5
