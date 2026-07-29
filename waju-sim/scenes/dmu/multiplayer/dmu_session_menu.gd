extends Control

@onready var address_input: LineEdit = %AddressInput
@onready var port_input: SpinBox = %PortInput
@onready var password_input: LineEdit = %PasswordInput
@onready var role_select: OptionButton = %RoleSelect
@onready var status_label: Label = %StatusLabel


func _ready() -> void:
	for role: String in Global.ROLE_KEYS:
		role_select.add_item(Global.ROLE_NAMES[role])
	role_select.select(SavedVariables.save_data["settings"]["player_role"])
	var session := get_node("/root/DmuSession")
	if !session.last_server_address.is_empty():
		address_input.text = session.last_server_address
		port_input.value = session.last_server_port
		password_input.text = session.last_server_password
	session.join_rejected.connect(_on_join_rejected)


func _on_solo_pressed() -> void:
	get_node("/root/DmuSession").start_solo()
	var selected_seq: int = DmuSavedVariables.get_data("settings", "selected_seq")
	var scene_paths := ["uid://cwyllh1xj6q5a", "uid://bcoqkgenftan6", "uid://cxro2gan53o1k", "uid://bilj5u4ew64sp"]
	get_tree().change_scene_to_packed(load(scene_paths[selected_seq]))


func _on_connect_pressed() -> void:
	status_label.text = "Connecting..."
	var role: String = Global.ROLE_KEYS[role_select.selected]
	var config: Dictionary = DmuSavedVariables.save_data["settings"].duplicate(true)
	var result: Error = get_node("/root/DmuSession").connect_to_server(address_input.text.strip_edges(), int(port_input.value), role, config, password_input.text)
	if result != OK:
		status_label.text = "Connection setup failed: %s" % error_string(result)


func _on_join_rejected(reason: String) -> void:
	status_label.text = reason