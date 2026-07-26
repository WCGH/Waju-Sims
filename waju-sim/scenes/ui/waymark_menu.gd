# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

class_name WaymarkMenu


@onready var menu_container: MarginContainer = %MenuContainer
@onready var wm_ground_marker: MeshInstance3D = %WMGroundMarker
@onready var waymark_controller: WaymarkController = %WaymarkController
@onready var import_container: MarginContainer = %ImportContainer
@onready var preset_labels: Dictionary = {
	"preset_1": %Preset1Label, "preset_2": %Preset2Label, "preset_3": %Preset3Label,
	 "custom_1": %Custom1Label, "custom_2": %Custom2Label
}

var camera: Camera3D
var circle_active := false
var selected_key: String
var ray_collision: Dictionary


func _ready() -> void:
	set_all_names()


func _process(_delta: float) -> void:
	if !circle_active:
		set_process(false)
		return
	# Check for left click
	if Input.is_action_just_pressed("left_click"):
		# Mouse will have moved so we use last ray_collision if valid
		if !ray_collision.is_empty():
			place_waymark()
			return
	if Input.is_action_just_pressed("right_click"):
		clear_waymark()
		return
	ray_collision = camera.get_first_ray_collision_with_floor(get_viewport().get_mouse_position())
	# Check if mouse cursor is off map
	if ray_collision.is_empty():
		wm_ground_marker.visible = false
		return
	# Move ground marker to mouse position
	wm_ground_marker.visible = true
	wm_ground_marker.global_position.x = ray_collision["position"].x
	wm_ground_marker.global_position.z = ray_collision["position"].z


func place_waymark():
	circle_active = false
	wm_ground_marker.visible = false
	waymark_controller.move_waymark(selected_key, Vector2(ray_collision["position"].x, ray_collision["position"].z))


func clear_waymark():
	circle_active = false
	wm_ground_marker.visible = false
	waymark_controller.clear_wm(selected_key)


# Hide/Show Menu Container
func _on_collapse_button_pressed() -> void:
	menu_container.visible = !menu_container.visible


func wm_button_pressed(wm_key: String):
	if !camera:
		camera = get_tree().get_first_node_in_group("player").get_camera()
	circle_active = true
	selected_key = wm_key
	set_process(true)


func set_all_names():
	for i in waymark_controller.menu_slot_keys.size():
		set_slot_name(i)


func set_slot_name(menu_slot_key: int):
	var key = waymark_controller.menu_slot_keys[menu_slot_key]
	# Preset 1, 2, 3
	if Global.get_encounter_waymarks().has(key):
		if Global.get_encounter_waymarks()[key].has("name"):
			preset_labels[key].set_text(Global.get_encounter_waymarks()[key]["name"])
	# Custom 1, 2
	else:
		if SavedVariables.get_encounter_data("waymarks", key).has("name"):
			preset_labels[key].set_text(
				SavedVariables.get_encounter_data("waymarks", key)["name"])


func reset_slot_name(menu_slot_key: int):
	var slot_name = "Custom 1" if menu_slot_key == 3 else "Custom 2"
	var dict: Dictionary = SavedVariables.get_encounter_data("waymarks", waymark_controller.menu_slot_keys[menu_slot_key])
	dict.set("name", slot_name)
	set_slot_name(menu_slot_key)


func _on_button_a_pressed() -> void:
	wm_button_pressed("wm_a")


func _on_button_b_pressed() -> void:
	wm_button_pressed("wm_b")


func _on_button_c_pressed() -> void:
	wm_button_pressed("wm_c")


func _on_button_d_pressed() -> void:
	wm_button_pressed("wm_d")


func _on_button_1_pressed() -> void:
	wm_button_pressed("wm_1")


func _on_button_2_pressed() -> void:
	wm_button_pressed("wm_2")


func _on_button_3_pressed() -> void:
	wm_button_pressed("wm_3")


func _on_button_4_pressed() -> void:
	wm_button_pressed("wm_4")


func _on_button_clear_pressed() -> void:
	waymark_controller.clear_all_wm()


func _on_button_slot_1_pressed() -> void:
	waymark_controller.set_preset_markers(0)


func _on_button_slot_2_pressed() -> void:
	waymark_controller.set_preset_markers(1)


func _on_button_slot_3_pressed() -> void:
	waymark_controller.set_preset_markers(2)


func _on_button_slot_4_pressed() -> void:
	waymark_controller.set_preset_markers(3)


func _on_button_slot_5_pressed() -> void:
	waymark_controller.set_preset_markers(4)


func _on_save_button_4_pressed() -> void:
	waymark_controller.save_custom_preset(3)
	reset_slot_name(3)


func _on_save_button_5_pressed() -> void:
	waymark_controller.save_custom_preset(4)
	reset_slot_name(4)


func _on_import_button_pressed() -> void:
	import_container.show()
