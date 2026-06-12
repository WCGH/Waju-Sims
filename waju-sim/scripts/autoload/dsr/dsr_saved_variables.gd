# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

#signal keybind_changed(keybinds: Dictionary)

const CONFIG_FILE_PATH = "user://dsr_config.cfg"

# General
enum strats {APD, LPDU, TWIN}
enum markers {APD, LPDU}
# P3
enum nidhogg {WEST, EAST, DEFAULT = -1}
enum in_line {RANDOM, ONE, TWO, THREE, DEFAULT = -1}
enum arrow {RANDOM, UP, CIRCLE, DOWN, DEFAULT = -1}
# P5
enum dooms {ANCHOR, STATIC, DEFAULT = -1}
# P6
enum first_vow {RANDOM, M1, M2, R1, R2, DEFAULT = -1}
enum wroth {STATIC, J_RELATIVE, DEFAULT = -1}
enum wb_1 {HEALERS, RANGED, G1, DEFAULT = -1}
enum wb_2 {FNOS, STATIC, DEFAULT = -1}
enum t_markers {AM, MANUAL, NONE, DEFAULT = -1}

var config_file: ConfigFile
var save_data: Dictionary = {
	"settings": {
		"selected_seq": 0,
		#"player_role": 0,
		#"screen_res": Vector2i(1600, 900),
		#"maximized": false,
		#"camera_distance": 22,
		"strat": strats.APD,
		"markers": markers.APD,
		#"mouse_sens": 1.0,
		#"x_sens": 1.0,
		#"y_sens": 1.0,
		#"invert_y": false
	},
	"p3": {
		"nidhogg": 0,
		"in_line": 0,
		"arrow": 0
	},
	"p5": {
		"lineup": ["r1", "m1", "t1", "h1", "h2", "t2", "m2", "r2"],
		"dooms": 0
	},
	"p6": {
		"first_vow": 0,
		"wroth": 0,
		"wb_1": 0,
		"wb_2": 0,
		"t_markers": 0
	},
	#"keybinds": {
		#"ab1_sprint": KEY_1,
		#"ab2_arms": KEY_2,
		#"ab3_dash": KEY_3
	#},
	## DSR Waymarks
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

var defaults := {
	strats.APD: {
		"p3": { 
			"nidhogg": nidhogg.WEST, "in_line": in_line.RANDOM, "arrow": arrow.RANDOM},
		"p5": { 
			"dooms": dooms.ANCHOR },
		"p6": {
			"first_vow": first_vow.RANDOM, "wroth": wroth.STATIC,
			"wb_1": wb_1.HEALERS, "wb_2": wb_2.STATIC, "t_markers": t_markers.AM
		}
	},
	strats.LPDU: {
		"p3": { 
			"nidhogg": nidhogg.EAST, "in_line": in_line.RANDOM, "arrow": arrow.RANDOM },
		"p5": { 
			"dooms": dooms.ANCHOR },
		"p6": { 
			"first_vow": first_vow.RANDOM, "wroth": wroth.STATIC,
			"wb_1": wb_1.G1, "wb_2": wb_2.FNOS, "t_markers": t_markers.AM
		}
	},
	strats.TWIN: {
		"p3": { 
			"nidhogg": nidhogg.EAST, "in_line": in_line.RANDOM, "arrow": arrow.RANDOM },
		"p5": { 
			"dooms": dooms.STATIC },
		"p6": { 
			"first_vow": first_vow.RANDOM, "wroth": wroth.J_RELATIVE,
			"wb_1": wb_1.G1, "wb_2": wb_2.FNOS, "t_markers": t_markers.MANUAL}
	}
}

#var input_action_keys := ["ab1_sprint", "ab2_arms", "ab3_dash"]


func _ready() -> void:
	GameEvents.dsr_variable_saved.connect(on_variable_saved)
	config_file = ConfigFile.new()
	load_save_file()
	set_defaults()
	#set_keybinds()
	save()


func get_data(category: String, key: String) -> Variant:
	if save_data[category][key] is int:
		if save_data[category][key] == -1:
			return defaults[save_data["settings"]["strat"]][category][key]
	return save_data[category][key]


# TODO: Replace old validation with version check.
func load_save_file() -> void:
	var _err := config_file.load(CONFIG_FILE_PATH)
	
	## Fix out of date settings.
	#if config_file.has_section_key("settings", "strat") and config_file.get_value("settings", "strat") is String:
		#config_file.set_value("settings", "strat", save_data["settings"]["strat"])
	#if config_file.has_section_key("settings", "lineup") and config_file.has_section_key("settings", "lineup"):
		#config_file.set_value("settings", "lineup", null)
	#
	## Validate enums.
	#if config_file.has_section_key("settings", "strat") and config_file.get_value("settings", "strat") > 2:
		#config_file.set_value("settings", "strat", save_data["settings"]["strat"])
	#if config_file.has_section_key("settings", "markers") and config_file.get_value("settings", "markers") > 1:
		#config_file.set_value("settings", "markers", save_data["settings"]["markers"])
	#if config_file.has_section_key("p3", "nidhogg") and config_file.get_value("p3", "nidhogg") > 1:
		#config_file.set_value("p3", "nidhogg", save_data["p3"]["nidhogg"])
	#if config_file.has_section_key("p5", "dooms") and config_file.get_value("p5", "dooms") > 1:
		#config_file.set_value("p5", "dooms", save_data["p5"]["dooms"])
	#if config_file.has_section_key("p6", "wb_1") and config_file.get_value("p6", "wb_1") > 2:
		#config_file.set_value("p6", "wb_1", save_data["p6"]["wb_1"])
	#if config_file.has_section_key("p6", "wb_2") and config_file.get_value("p6", "wb_2") > 1:
		#config_file.set_value("p6", "wb_2", save_data["p6"]["wb_2"])
	#if config_file.has_section_key("p6", "t_markers") and config_file.get_value("p6", "t_markers") > 2:
		#config_file.set_value("p6", "wb_2", save_data["p6"]["wb_2"])
	
	# Load data.
	for section in config_file.get_sections():
		for key in config_file.get_section_keys(section):
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
	save_data[section][key] = value
	config_file.set_value(section, key, value)
	save()
	#if section == "keybinds":
		#set_keybinds()


#func set_keybinds() -> void:
	#for key: String in save_data["keybinds"]:
		#var new_key_event := InputEventKey.new()
		#new_key_event.set_keycode(save_data["keybinds"][key])
		#if !InputMap.action_has_event(key, new_key_event):
			#InputMap.action_erase_events(key)
			#InputMap.action_add_event(key, new_key_event)
	#keybind_changed.emit(save_data["keybinds"])


#func get_keybinds() -> Dictionary:
	#return save_data["keybinds"]


#func get_screen_res() -> Vector2i:
	#return save_data["settings"]["screen_res"]


func get_default(category: String, key: String) -> int:
	#var a = defaults[strats.APD][category][key]
	return defaults[save_data["settings"]["strat"]][category][key]
