extends Node3D

class_name CelestTowers


const S_SET_POS := [Vector3(14.784, 0, 17.619), Vector3(0, 0, 23), Vector3(-14.784, 0, 17.619)]
const NW_SET_POS := [Vector3(-22.651, 0, 3.994), Vector3(-19.919, 0, -11.5), Vector3(-7.866, 0, -21.613)]
const NE_SET_POS := [Vector3(7.866, 0, -21.613), Vector3(19.919, 0, -11.5), Vector3(22.651, 0, 3.994)]

@onready var towers := {
	"light": [$LightTower1, $LightTower2, $LightTower3],
	"ice": [$IceTower1, $IceTower2, $IceTower3],
	"fire": [$FireTower1, $FireTower2, $FireTower3]
}

var tower_positions := {"light": [], "ice": [], "fire": []}
var active_towers := {"light": [], "ice": [], "fire": []}
var double_active_order := ["light", "ice", "fire"]
var tower_set_order := ["light", "ice", "fire"]   # S,NW,NE
var current_set_index := 0


func show_towers():
	self.show()
	# Randomize tower set positions
	tower_set_order.shuffle()
	var set_pos_arrays = [S_SET_POS, NW_SET_POS, NE_SET_POS]
	for i in tower_set_order.size():
		var key = tower_set_order[i]
		for j in towers[key].size():
			# Move to pos and show
			towers[key][j].global_position = set_pos_arrays[i][j]
			towers[key][j].show_tower()


func hide_towers():
	for key: String in towers:
		for tower: CLTower in towers[key]:
			tower.hide_tower()


func show_active_towers_glow():
	for key in towers:
		for i in active_towers[key]:
			towers[key][i].show_glow()


# Call before assigning new active towers.
func hide_active_towers_glow():
	for key in towers:
		for i in active_towers[key]:
			towers[key][i].hide_glow()


func activate_towers(set_index: int):
	if set_index == 0:
		# Randomize first active towers
		double_active_order.shuffle()
		var active_tower_indexes := [0, 1, 2]
		active_tower_indexes.remove_at(randi_range(0, 2))
		active_towers[double_active_order[0]] = active_tower_indexes
		active_towers[double_active_order[1]].append(randi_range(0, 2))
		active_towers[double_active_order[2]].append(randi_range(0, 2))
		show_active_towers_glow()
	elif set_index <= 2:
		hide_active_towers_glow()
		current_set_index = set_index
		# Active tower for previous double and new double are deterministic
		# Previous double
		#var double_set_index: int = set_index - 1
		var prev_double_active_indexes: Array = active_towers[double_active_order[set_index - 1]]
		assert(prev_double_active_indexes.size() == 2)
		var active_indexes: Array = [0, 1, 2]
		active_indexes.erase(prev_double_active_indexes[0])
		active_indexes.erase(prev_double_active_indexes[1])
		active_towers[double_active_order[set_index - 1]] = active_indexes
		# New double
		var prev_index: Array = active_towers[double_active_order[set_index]]
		assert(prev_index.size() == 1)
		active_indexes = [0, 1, 2]
		active_indexes.erase(prev_index[0])
		active_towers[double_active_order[set_index]] = active_indexes
		# Final set is random, but can't be same as previous
		var rand_set_index = set_index + 1 
		if rand_set_index == 3:
			rand_set_index = 0
		prev_index = active_towers[double_active_order[rand_set_index]]
		assert(prev_index.size() == 1)
		active_indexes = [0, 1, 2]
		active_indexes.erase(prev_index[0])
		active_indexes = [active_indexes.pick_random()]
		active_towers[double_active_order[rand_set_index]] = active_indexes
		show_active_towers_glow()
	# For last set, just need to hide glow.
	else:
		hide_active_towers_glow()


# Returns the first cw tower to be soaked based on the player's starting debuff
# and the set index they will be soaking.
func get_first_tower_soak_cw(starting_debuff: String, set_index: int) -> CLTower:
	var next_set_key = tower_set_order[(tower_set_order.find(starting_debuff) + set_index + 1) % 3]
	var active_tower_indexes: Array = active_towers[next_set_key]
	active_tower_indexes.sort()
	return towers[next_set_key][active_tower_indexes[0]]


# Returns second tower cw in the double tower for current set.
func get_double_tower_cw() -> CLTower:
	var double_active_key = double_active_order[current_set_index]
	var active_tower_indexes: Array = active_towers[double_active_key]
	assert(active_tower_indexes.size() == 2)
	active_tower_indexes.sort()
	return towers[double_active_key][active_tower_indexes[1]]
