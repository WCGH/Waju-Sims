# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## This file handles FRU exclusive saved variables.

extends Node

#signal keybind_changed(keybinds: Dictionary)

const CONFIG_FILE_PATH = "user://dmu_config.cfg"

var config_file: ConfigFile
var save_data: Dictionary = {
	## DMU settings
	"settings": {
		"selected_seq": 0,
		"p2_fors_strat": 0, # [UATE, Kefkabin]
		"p2_fors_soak_order": 0,
		"p2_fors_adjust_prio": 0,
		"p2_fors_odd_tower_pos": 0,
		"p2_fors_even_tower_pos": 0,
		"p2_fors_special_rule": false,
		"p2_fors_bait": false,
		"p3_boa_t1_chaos": true,
		"p3_boa_strat": 0,
		"p3_boa_start_point": 0,
		#"p4_ct_aero_plant": false,
	},
	## FRU Waymarks
	"waymarks": {
		"active": "preset_1",
		"custom_1": {
			"name": "Custom 1",
			"wm_a": Waymarks.HIDE_VECTOR, "wm_b": Waymarks.HIDE_VECTOR, "wm_c": Waymarks.HIDE_VECTOR, "wm_d": Waymarks.HIDE_VECTOR,
			"wm_1": Waymarks.HIDE_VECTOR, "wm_2": Waymarks.HIDE_VECTOR, "wm_3": Waymarks.HIDE_VECTOR, "wm_4": Waymarks.HIDE_VECTOR,
		},
		"custom_2": {
			"name": "Custom 2",
			"wm_a": Waymarks.HIDE_VECTOR, "wm_b": Waymarks.HIDE_VECTOR, "wm_c": Waymarks.HIDE_VECTOR, "wm_d": Waymarks.HIDE_VECTOR,
			"wm_1": Waymarks.HIDE_VECTOR, "wm_2": Waymarks.HIDE_VECTOR, "wm_3": Waymarks.HIDE_VECTOR, "wm_4": Waymarks.HIDE_VECTOR,
		}
	}
}


func _ready() -> void:
	GameEvents.dmu_variable_saved.connect(on_variable_saved)
	config_file = ConfigFile.new()
	load_save_file()
	set_defaults()
	save()


func get_data(category: String, key: String) -> Variant:
	return save_data[category][key]


# Validates data as a integer within the given range before returning it.
func get_data_and_check_int(category: String, key: String, range_min: int, range_max: int) -> int:
	if save_data[category][key] is int\
		and save_data[category][key] > range_min and save_data[category][key] < range_max:
		return save_data[category][key]
	else:
		GameEvents.emit_encounter_variable_saved(category, key, range_min)
		return range_min


func get_data_and_check_bool(category: String, key: String) -> bool:
	if save_data[category][key] is bool:
		return save_data[category][key]
	else:
		GameEvents.emit_encounter_variable_saved(category, key, false)
		return false


func has_data(category: String, key: String) -> bool:
	if save_data.has(category):
		return save_data[category].has(key)
	return false


func load_save_file() -> void:
	var _err := config_file.load(CONFIG_FILE_PATH)
	# Load data.
	for section in config_file.get_sections():
		for key in config_file.get_section_keys(section):
			if not save_data.has(section):
				save_data[section] = {}
			save_data[section][key] = config_file.get_value(section, key)


func save() -> void:
	var err := config_file.save(CONFIG_FILE_PATH)
	if err != OK:
		print("Error saving config file: ", err)


func set_defaults() -> void:
	for section: String in save_data:
		for key: String in save_data[section]:
			config_file.set_value(section, key, save_data[section][key])


func on_variable_saved(section: String, key: String, value: Variant) -> void:
	if not save_data.has(section):
		save_data[section] = {}
	save_data[section][key] = value
	config_file.set_value(section, key, value)
	save()
