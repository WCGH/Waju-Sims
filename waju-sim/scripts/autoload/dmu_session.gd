extends Node

signal session_ready
signal roster_changed
signal leader_changed(peer_id: int)
signal join_rejected(reason: String)
signal role_change_rejected(reason: String)

enum Mode { SOLO, MULTIPLAYER }

const DEFAULT_PORT := 7000
const UPDATE_INTERVAL := 0.05

var mode := Mode.SOLO
var local_role_key := ""
var role_owners: Dictionary = {}
var leader_peer_id := 0
var phase_config: Dictionary = {}
var _local_character
var _state_elapsed := 0.0
var _server_mode := false
var _applying_phase_config := false
var session_paused := false
var _ui_process_modes: Dictionary = {}
var phase_seed := 0
var _random := RandomNumberGenerator.new()
var _reported_failures: Dictionary = {}
var _server_password := ""
var _allowed_ips: Array[String] = []
var _restart_in_progress := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	GameEvents.dmu_variable_saved.connect(_on_dmu_variable_saved)
	_server_mode = "--server" in _get_command_line_args()
	if _server_mode:
		start_server(_get_server_port())


func is_server_mode() -> bool:
	return _server_mode


func is_multiplayer_session() -> bool:
	return mode == Mode.MULTIPLAYER


func start_server(port: int) -> Error:
	_random.randomize()
	_server_password = _get_command_line_option("--password")
	_allowed_ips = _get_allowed_ips()
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_server(port)
	if result != OK:
		push_error("Unable to start DMU server on port %d: %s" % [port, error_string(result)])
		return result
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	print("DMU relay server listening on port %d" % port)
	if !_allowed_ips.is_empty():
		print("DMU relay IP allow-list enabled")
	return OK


func connect_to_server(address: String, port: int, requested_role: String, config: Dictionary,
		password := "") -> Error:
	mode = Mode.MULTIPLAYER
	local_role_key = requested_role
	var peer := ENetMultiplayerPeer.new()
	var result := peer.create_client(address, port)
	if result != OK:
		return result
	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server, CONNECT_ONE_SHOT)
	multiplayer.connection_failed.connect(_on_connection_failed, CONNECT_ONE_SHOT)
	phase_config = config.duplicate(true)
	_server_password = password
	return OK


func start_solo() -> void:
	mode = Mode.SOLO
	local_role_key = Global.ROLE_KEYS[SavedVariables.save_data["settings"]["player_role"]]
	role_owners.clear()
	phase_config.clear()


func change_to_phase(selected_seq: int) -> void:
	if selected_seq < 0 or selected_seq >= _get_phase_scene_paths().size():
		push_error("Invalid DMU phase index: %d" % selected_seq)
		return
	if is_multiplayer_session() and phase_seed != 0:
		seed(phase_seed)
	get_tree().change_scene_to_packed(load(_get_phase_scene_paths()[selected_seq]))


func request_phase_change(selected_seq: int) -> void:
	if !is_multiplayer_session():
		change_to_phase(selected_seq)
		return
	if multiplayer.get_unique_id() != leader_peer_id:
		return
	request_phase_change_on_server.rpc_id(1, selected_seq)


func request_role_change(requested_role: String) -> void:
	if !is_multiplayer_session() or requested_role == local_role_key:
		return
	request_role_change_on_server.rpc_id(1, requested_role)


func register_character(character: Node) -> void:
	if is_multiplayer_session() and character.role_key == local_role_key:
		_local_character = character


func _process(delta: float) -> void:
	if !is_multiplayer_session() or _server_mode or !is_instance_valid(_local_character):
		return
	_state_elapsed += delta
	if _state_elapsed < UPDATE_INTERVAL:
		return
	_state_elapsed = 0.0
	receive_character_state.rpc_id(1, local_role_key, _local_character.global_position,
		_local_character.rotation.y)


func request_pause(paused: bool) -> void:
	if !is_multiplayer_session():
		get_tree().paused = paused
		return
	request_pause_change.rpc_id(1, paused)


func request_restart() -> void:
	if !is_multiplayer_session():
		get_tree().reload_current_scene()
		return
	request_restart_change.rpc_id(1)


func request_fail(text: String) -> void:
	if !is_multiplayer_session() or _restart_in_progress:
		return
	if !text.begins_with("Player ") and multiplayer.get_unique_id() != leader_peer_id:
		return
	if text.begins_with("Player "):
		text = "%s%s" % [Global.ROLE_NAMES[local_role_key], text.trim_prefix("Player")]
	request_fail_on_server.rpc_id(1, text)


func request_leader_transfer_to_next_peer() -> void:
	if !is_multiplayer_session() or multiplayer.get_unique_id() != leader_peer_id:
		return
	var peers: Array = []
	for peer_id: int in role_owners.values():
		if peer_id != leader_peer_id and peer_id not in peers:
			peers.append(peer_id)
	if !peers.is_empty():
		request_leader_transfer_to_peer(peers[0])


func request_leader_transfer_to_peer(target_peer_id: int) -> void:
	if !is_multiplayer_session() or multiplayer.get_unique_id() != leader_peer_id:
		return
	if target_peer_id == leader_peer_id or target_peer_id not in role_owners.values():
		return
	request_leader_transfer.rpc_id(1, target_peer_id)


func _on_connected_to_server() -> void:
	request_join.rpc_id(1, local_role_key, phase_config, _server_password)


func _on_connection_failed() -> void:
	push_error("Unable to connect to DMU server")
	mode = Mode.SOLO


@rpc("any_peer", "reliable")
func request_join(requested_role: String, requested_config: Dictionary, password: String) -> void:
	if !_server_mode:
		return
	var peer_id := multiplayer.get_remote_sender_id()
	if !_is_peer_allowed(peer_id):
		receive_join_rejected.rpc_id(peer_id, "Your IP address is not allowed by this server")
		return
	if !_server_password.is_empty() and password != _server_password:
		receive_join_rejected.rpc_id(peer_id, "Incorrect server password")
		return
	var role := _claim_role(peer_id, requested_role)
	if role.is_empty():
		receive_join_rejected.rpc_id(peer_id, "Role %s is already taken" % requested_role)
		return
	if phase_config.is_empty():
		phase_config = requested_config.duplicate(true)
	if phase_seed == 0:
		phase_seed = _new_phase_seed()
	if leader_peer_id == 0:
		leader_peer_id = peer_id
	print("DMU peer %d joined as %s" % [peer_id, role])
	receive_session_snapshot.rpc_id(peer_id, role, role_owners, leader_peer_id, phase_config,
		session_paused, phase_seed)
	broadcast_roster()


@rpc("authority", "reliable")
func receive_join_rejected(reason: String) -> void:
	mode = Mode.SOLO
	multiplayer.multiplayer_peer.close()
	join_rejected.emit(reason)


@rpc("authority", "reliable")
func receive_session_snapshot(assigned_role: String, owners: Dictionary, leader: int,
		config: Dictionary, paused: bool, new_phase_seed: int) -> void:
	mode = Mode.MULTIPLAYER
	local_role_key = assigned_role
	role_owners = owners.duplicate(true)
	leader_peer_id = leader
	phase_config = config.duplicate(true)
	session_paused = paused
	phase_seed = new_phase_seed
	DmuSavedVariables.save_data["settings"] = phase_config.duplicate(true)
	session_ready.emit()
	_load_selected_phase.call_deferred()


@rpc("authority", "reliable")
func receive_roster(owners: Dictionary, leader: int) -> void:
	role_owners = owners.duplicate(true)
	leader_peer_id = leader
	roster_changed.emit()
	leader_changed.emit(leader_peer_id)


@rpc("any_peer", "unreliable_ordered")
func receive_character_state(role: String, position: Vector3, rotation_y: float) -> void:
	if !_server_mode:
		var character = _find_character(role)
		if character != null and role != local_role_key:
			character.apply_remote_state(position, rotation_y)
		return
	var peer_id := multiplayer.get_remote_sender_id()
	if role_owners.get(role, 0) != peer_id:
		return
	receive_character_state.rpc(role, position, rotation_y)


@rpc("any_peer", "reliable")
func request_pause_change(paused: bool) -> void:
	if !_server_mode or multiplayer.get_remote_sender_id() != leader_peer_id:
		return
	apply_pause.rpc(paused)


@rpc("authority", "reliable", "call_local")
func apply_pause(paused: bool) -> void:
	session_paused = paused
	get_tree().paused = paused
	_set_ui_pause_processing(paused)
	var pause_menu := get_tree().get_first_node_in_group("pause_menu")
	if pause_menu != null:
		pause_menu.visible = paused


@rpc("any_peer", "reliable")
func request_restart_change() -> void:
	if !_server_mode or multiplayer.get_remote_sender_id() != leader_peer_id:
		return
	phase_seed = _new_phase_seed()
	_reported_failures.clear()
	apply_restart.rpc(phase_seed, session_paused)


@rpc("any_peer", "reliable")
func request_role_change_on_server(requested_role: String) -> void:
	if !_server_mode or requested_role not in Global.ROLE_KEYS:
		return
	var peer_id := multiplayer.get_remote_sender_id()
	var current_role := _get_role_for_peer(peer_id)
	if current_role.is_empty():
		return
	if role_owners.has(requested_role):
		receive_role_change_rejected.rpc_id(peer_id, "Role %s is already taken" % requested_role)
		return
	role_owners.erase(current_role)
	role_owners[requested_role] = peer_id
	apply_role_change.rpc(peer_id, requested_role)
	broadcast_roster()


@rpc("authority", "reliable")
func receive_role_change_rejected(reason: String) -> void:
	role_change_rejected.emit(reason)


@rpc("authority", "reliable")
func apply_role_change(peer_id: int, assigned_role: String) -> void:
	if multiplayer.get_unique_id() == peer_id:
		local_role_key = assigned_role
		GameEvents.emit_variable_saved("settings", "player_role", Global.ROLE_KEYS.find(assigned_role))
	get_tree().reload_current_scene()


@rpc("any_peer", "reliable")
func request_phase_change_on_server(selected_seq: int) -> void:
	if !_server_mode or multiplayer.get_remote_sender_id() != leader_peer_id:
		return
	if selected_seq < 0 or selected_seq >= _get_phase_scene_paths().size():
		return
	phase_config["selected_seq"] = selected_seq
	phase_seed = _new_phase_seed()
	_reported_failures.clear()
	apply_phase_change.rpc(selected_seq, phase_seed)


@rpc("authority", "reliable")
func apply_phase_change(selected_seq: int, new_phase_seed: int) -> void:
	phase_config["selected_seq"] = selected_seq
	phase_seed = new_phase_seed
	GameEvents.emit_encounter_variable_saved("settings", "selected_seq", selected_seq)
	_restart_in_progress = true
	change_to_phase(selected_seq)
	_finish_phase_change.call_deferred()


func _finish_phase_change() -> void:
	await get_tree().process_frame
	_restart_in_progress = false
	if session_paused:
		apply_pause(true)


@rpc("any_peer", "reliable")
func request_config_change(key: String, value: Variant) -> void:
	if !_server_mode or multiplayer.get_remote_sender_id() != leader_peer_id:
		return
	if !phase_config.has(key):
		return
	phase_config[key] = value
	apply_config_change.rpc(key, value)


@rpc("authority", "reliable")
func apply_config_change(key: String, value: Variant) -> void:
	phase_config[key] = value
	_applying_phase_config = true
	GameEvents.emit_encounter_variable_saved("settings", key, value)
	_applying_phase_config = false


@rpc("any_peer", "reliable")
func request_leader_transfer(target_peer_id: int) -> void:
	if !_server_mode or multiplayer.get_remote_sender_id() != leader_peer_id:
		return
	if target_peer_id in role_owners.values():
		leader_peer_id = target_peer_id
		broadcast_roster()


@rpc("authority", "reliable", "call_local")
func apply_restart(new_phase_seed: int, paused: bool) -> void:
	session_paused = paused
	phase_seed = new_phase_seed
	seed(phase_seed)
	if _server_mode:
		return
	_restart_in_progress = true
	get_tree().paused = false
	_set_ui_pause_processing(false)
	get_tree().reload_current_scene()
	_finish_restart.call_deferred()


func _finish_restart() -> void:
	await get_tree().process_frame
	_restart_in_progress = false
	if session_paused:
		apply_pause(true)


@rpc("any_peer", "reliable")
func request_fail_on_server(text: String) -> void:
	if !_server_mode or _get_role_for_peer(multiplayer.get_remote_sender_id()).is_empty():
		return
	_accept_fail_after_disconnect_check.call_deferred(multiplayer.get_remote_sender_id(), text)


func _accept_fail_after_disconnect_check(peer_id: int, text: String) -> void:
	await get_tree().create_timer(0.1).timeout
	if peer_id not in multiplayer.get_peers() or _get_role_for_peer(peer_id).is_empty():
		return
	if _reported_failures.has(text):
		return
	_reported_failures[text] = true
	apply_fail.rpc(text)


@rpc("authority", "reliable")
func apply_fail(text: String) -> void:
	var fail_list := get_tree().get_first_node_in_group("fail_list")
	if fail_list != null:
		fail_list.add_synced_fail(text)


func _claim_role(peer_id: int, requested_role: String) -> String:
	if requested_role not in Global.ROLE_KEYS or role_owners.has(requested_role):
		return ""
	role_owners[requested_role] = peer_id
	return requested_role


func _get_role_for_peer(peer_id: int) -> String:
	for role: String in role_owners:
		if role_owners[role] == peer_id:
			return role
	return ""


func _new_phase_seed() -> int:
	return _random.randi_range(1, 2147483647)


func _on_peer_disconnected(peer_id: int) -> void:
	for role: String in role_owners:
		if role_owners[role] == peer_id:
			role_owners.erase(role)
			break
	if leader_peer_id == peer_id:
		leader_peer_id = 0
		for remaining_peer_id: int in role_owners.values():
			leader_peer_id = remaining_peer_id
			break
	broadcast_roster()


func broadcast_roster() -> void:
	receive_roster.rpc(role_owners, leader_peer_id)


func _load_selected_phase() -> void:
	if _server_mode:
		return
	var selected_seq: int = phase_config.get("selected_seq", 0)
	change_to_phase(selected_seq)
	if session_paused:
		get_tree().paused = true
		_apply_pause_after_phase_load.call_deferred()


func _apply_pause_after_phase_load() -> void:
	await get_tree().process_frame
	if session_paused:
		apply_pause(true)


func _get_phase_scene_paths() -> Array[String]:
	return ["uid://cwyllh1xj6q5a", "uid://bcoqkgenftan6", "uid://cxro2gan53o1k", "uid://bilj5u4ew64sp"]


func _get_server_port() -> int:
	var port_option := _get_command_line_option("--port")
	if !port_option.is_empty():
		var port := port_option.to_int()
		if port > 0 and port <= 65535:
			return port
	return DEFAULT_PORT


func _get_command_line_option(option: String) -> String:
	var args := _get_command_line_args()
	var option_index := args.find(option)
	if option_index >= 0 and option_index + 1 < args.size():
		return args[option_index + 1]
	return ""


func _get_allowed_ips() -> Array[String]:
	var allowed_ips: Array[String] = []
	var args := _get_command_line_args()
	for index in args.size():
		if args[index] != "--allow-ip" or index + 1 >= args.size():
			continue
		for address in args[index + 1].split(",", false):
			var normalized_address := address.strip_edges()
			if !normalized_address.is_empty() and normalized_address not in allowed_ips:
				allowed_ips.append(normalized_address)
	return allowed_ips


func _is_peer_allowed(peer_id: int) -> bool:
	if _allowed_ips.is_empty():
		return true
	var enet_peer := multiplayer.multiplayer_peer as ENetMultiplayerPeer
	var remote_peer := enet_peer.get_peer(peer_id)
	return remote_peer != null and remote_peer.get_remote_address() in _allowed_ips


func _get_command_line_args() -> PackedStringArray:
	var args := OS.get_cmdline_args()
	args.append_array(OS.get_cmdline_user_args())
	return args


func _find_character(role: String):
	var characters_layer := get_tree().get_first_node_in_group("characters_layer")
	if characters_layer == null:
		return null
	for character: Node in characters_layer.get_children():
		if character.get("role_key") == role:
			return character
	return null


func _set_ui_pause_processing(paused: bool) -> void:
	if paused:
		_set_ui_process_mode(get_tree().root)
		return
	for node: Node in _ui_process_modes:
		if is_instance_valid(node):
			node.process_mode = _ui_process_modes[node]
	_ui_process_modes.clear()


func _set_ui_process_mode(node: Node) -> void:
	if node is CanvasLayer or node is BaseButton or node is LineEdit or node is SpinBox:
		if !_ui_process_modes.has(node):
			_ui_process_modes[node] = node.process_mode
		node.process_mode = Node.PROCESS_MODE_ALWAYS
	for child: Node in node.get_children():
		_set_ui_process_mode(child)


func _on_dmu_variable_saved(section: String, key: String, value: Variant) -> void:
	if section != "settings" or !is_multiplayer_session() or _applying_phase_config:
		return
	if !phase_config.has(key):
		return
	if multiplayer.get_unique_id() == leader_peer_id:
		request_config_change.rpc_id(1, key, value)
		return
	_applying_phase_config = true
	GameEvents.emit_encounter_variable_saved("settings", key, phase_config[key])
	_applying_phase_config = false