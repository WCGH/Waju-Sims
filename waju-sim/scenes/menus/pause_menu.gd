# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends CanvasLayer

@onready var pass_leadership_button: Button = %PassLeadershipButton
@onready var leadership_target_select: OptionButton = %LeadershipTargetSelect


func _ready() -> void:
	add_to_group("pause_menu")
	var session = get_node("/root/DmuSession")
	session.leader_changed.connect(_refresh_pass_leadership_button)
	session.session_ready.connect(_refresh_pass_leadership_button)
	session.roster_changed.connect(_refresh_pass_leadership_button)
	_refresh_pass_leadership_button()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		_on_pause_keybind_pressed()


func _on_pause_keybind_pressed() -> void:
	get_node("/root/DmuSession").request_pause(!get_tree().paused)


func _on_pass_leadership_pressed() -> void:
	var target_peer_id: Variant = leadership_target_select.get_selected_metadata()
	if target_peer_id is int:
		get_node("/root/DmuSession").request_leader_transfer_to_peer(target_peer_id)


func _refresh_pass_leadership_button(_leader_peer_id: int = 0) -> void:
	var session = get_node("/root/DmuSession")
	var in_multiplayer_session: bool = session.is_multiplayer_session()
	var is_leader: bool = multiplayer.get_unique_id() == session.leader_peer_id
	_populate_leadership_targets(session)
	pass_leadership_button.visible = in_multiplayer_session
	leadership_target_select.visible = in_multiplayer_session
	pass_leadership_button.disabled = !is_leader or leadership_target_select.item_count == 0
	leadership_target_select.disabled = !is_leader or leadership_target_select.item_count == 0
	if !is_leader:
		pass_leadership_button.tooltip_text = "Only the Party Leader can pass leadership."
	elif leadership_target_select.item_count == 0:
		pass_leadership_button.tooltip_text = "Another player must be connected before leadership can be passed."
	else:
		pass_leadership_button.tooltip_text = "Pass leadership to the selected player."


func _populate_leadership_targets(session: Node) -> void:
	leadership_target_select.clear()
	for role: String in Global.ROLE_KEYS:
		var peer_id: int = session.role_owners.get(role, 0)
		if peer_id == 0 or peer_id == session.leader_peer_id:
			continue
		leadership_target_select.add_item(Global.ROLE_NAMES[role])
		leadership_target_select.set_item_metadata(leadership_target_select.item_count - 1, peer_id)
