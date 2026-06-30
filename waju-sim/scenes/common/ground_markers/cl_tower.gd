extends Area3D

class_name CLTower

const AOE_RADIUS := 7.2
const AOE_LIFETIME := 0.3
const AOE_COLOR := {
	"light": Color(0.914, 0.902, 0.152, 0.638),
	"ice": Color(0.631, 0.702, 0.945, 0.687),
	"fire": Color(1.0, 0.6, 0.255, 0.662),
}

@export var element: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var gac: GroundAoeController = get_tree().get_first_node_in_group("ground_aoe_controller")


func show_tower():
	animation_player.play("grow_in")


func hide_tower():
	animation_player.play("fade_out")


func show_glow():
	animation_player.play("glow")


func hide_glow():
	animation_player.play("unglow")
	gac.spawn_circle(v2(self.global_position), AOE_RADIUS, AOE_LIFETIME, AOE_COLOR[element])


func get_bodies() -> Array:
	var bodies_hit := get_overlapping_bodies()
	return bodies_hit


func get_tower_element() -> String:
	return element


func v2(vec3: Vector3) -> Vector2:
	return Vector2(vec3.x, vec3.z)
