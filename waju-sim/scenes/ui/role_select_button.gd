# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends OptionButton

var role_feedback: Label


func _ready() -> void:
	selected = SavedVariables.save_data["settings"]["player_role"]
	var session := get_node("/root/DmuSession")
	if Global.encounter == Global.Encounter.DMU and session.is_multiplayer_session():
		selected = Global.ROLE_KEYS.find(session.local_role_key)
	if Global.encounter == Global.Encounter.DMU:
		session.role_change_rejected.connect(_on_role_change_rejected)
	role_feedback = Label.new()
	role_feedback.position = Vector2(0, size.y + 4)
	role_feedback.mouse_filter = Control.MOUSE_FILTER_IGNORE
	role_feedback.modulate = Color(1.0, 0.4, 0.4)
	role_feedback.z_index = 1
	role_feedback.hide()
	add_child(role_feedback)


func _on_item_selected(index : int) -> void:
	var session := get_node("/root/DmuSession")
	if Global.encounter == Global.Encounter.DMU and session.is_multiplayer_session():
		session.request_role_change(Global.ROLE_KEYS[index])
		selected = Global.ROLE_KEYS.find(session.local_role_key)
		return
	GameEvents.emit_variable_saved("settings", "player_role", index)


func _on_role_change_rejected(reason: String) -> void:
	role_feedback.text = reason
	role_feedback.show()
	var timer := get_tree().create_timer(3.0, true)
	timer.timeout.connect(role_feedback.hide)
