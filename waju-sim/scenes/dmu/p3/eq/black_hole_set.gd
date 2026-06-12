extends Node3D

#enum {North, East, South}

@onready var back_hole_node: Node3D = %BackHole1
@onready var set_13: Node3D = %Set13
@onready var set_24: Node3D = %Set24

var active_set: Node3D


func show_bh_set(set_index: int):
	match set_index:
		1, 3:
			active_set = set_13
		2, 4:
			active_set = set_24
		_:
			push_error("Invalid index given in show_bh_set.")
			return
	active_set.show()
	back_hole_node.play_fade_in()


func hide_bh_set():
	back_hole_node.play_fade_out()
	await get_tree().create_timer(1.0).timeout
	active_set.hide()


# Returns the tether node at the given cardinal.
# Cardinal index: 0=North, 1=East, 2=South
func get_bh_node(cardinal_index: int) -> Node3D:
	if !active_set:
		push_error("Error. `get_bh_node` was called before activating a set.")
		return null
	return active_set.get_child(cardinal_index).get_child(0)
