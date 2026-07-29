extends Button

@onready var role_select_button: OptionButton = get_node("../RoleSelectButton")


func _ready() -> void:
	pressed.connect(_on_pressed)
	_refresh_visibility()


func _refresh_visibility() -> void:
	var in_multiplayer: bool = get_node("/root/DmuSession").is_multiplayer_session()
	visible = in_multiplayer
	role_select_button.visible = !in_multiplayer


func _on_pressed() -> void:
	get_node("/root/DmuSession").disconnect_from_server()