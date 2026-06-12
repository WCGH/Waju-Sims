# WARN: Hardcoded resource paths. Should switch to UIDs.
# These should really be passed directly to the caller. This all needs a rewrite.

extends HBoxContainer

class_name MemberContainer


const PLAYER_LABEL = "Y.O.U."

# Preload icon textures
const _1_ICON = preload("res://assets/common/icons/ui_icons/1_icon.png")
const _2_ICON = preload("res://assets/common/icons/ui_icons/2_icon.png")
const _3_ICON = preload("res://assets/common/icons/ui_icons/3_icon.png")
const _4_ICON = preload("res://assets/common/icons/ui_icons/4_icon.png")
const _5_ICON = preload("res://assets/common/icons/ui_icons/5_icon.png")
const _6_ICON = preload("res://assets/common/icons/ui_icons/6_icon.png")
const _7_ICON = preload("res://assets/common/icons/ui_icons/7_icon.png")
const _8_ICON = preload("res://assets/common/icons/ui_icons/8_icon.png")
const DEBUFF_SCENE = preload("uid://cu7ghooei6mv5")

@onready var index_icons := [_1_ICON, _2_ICON, _3_ICON, _4_ICON, _5_ICON, _6_ICON, _7_ICON, _8_ICON]
@onready var index_icon_texture: TextureRect = $HBoxContainer/VBoxContainer/InfoLabels/IndexIconTexture
@onready var role_label: Label = $HBoxContainer/VBoxContainer/InfoLabels/RoleLabelScale/RoleLabel
@onready var aura_container: HBoxContainer = $AuraContainer
@onready var player_debuff_container : BoxContainer = get_tree().get_first_node_in_group("player_debuff_container")

var is_player := false
var _role_key: String


func set_as_player():
	is_player = true
	role_label.text = PLAYER_LABEL


func set_index_icon(index: int):
	assert(index >= 0 and index < index_icons.size())
	index_icon_texture.texture = index_icons[index]


func set_role_key(role_key: String):
	_role_key = role_key


func add_debuff(role_key : String, debuff_icon_scene : PackedScene, duration : float,
	stackable : bool, debuff_name : String,  stacks := 1) -> Signal:
	# Check if stackable debuff exists, if so, add a stack
	if stackable:
		var aura := get_aura(debuff_name)
		if aura:
			aura.add_stack(stacks)
			if is_player:
				var player_aura = get_player_aura(debuff_name)
				if player_aura:
					player_aura.add_stack(stacks)
			return aura.debuff_timeout
	# Else, instantiate new debuff
	var new_debuff : Debuff = DEBUFF_SCENE.instantiate()
	aura_container.add_child(new_debuff)
	new_debuff.set_debuff(debuff_icon_scene, role_key, duration, stackable, stacks)
	if is_player:
		var player_debuff : Debuff = DEBUFF_SCENE.instantiate()
		player_debuff_container.add_child(player_debuff)
		player_debuff.set_debuff(debuff_icon_scene, role_key, duration, stackable, stacks)
	return new_debuff.debuff_timeout


func remove_debuff(debuff_name: String):
	# Remove from party list debuffs
	var aura := get_aura(debuff_name)
	if !aura:
		return
	aura.queue_free()
	# Remove aura from player debuffs
	if is_player:
		var player_aura := get_player_aura(debuff_name)
		if !player_aura:
			return
		player_aura.queue_free()


func add_debuff_stacks(debuff_name: String, added_stacks: int):
	# Remove from party list debuffs
	var aura := get_aura(debuff_name)
	if !aura:
		return
	aura.add_stack(added_stacks)
	if is_player:
		var player_aura := get_player_aura(debuff_name)
		if !player_aura:
			return
		player_aura.add_stack(added_stacks)


func remove_debuff_stacks(debuff_name: String, removed_stacks: int):
	# Remove from party list debuffs
	var aura := get_aura(debuff_name)
	if !aura:
		return
	aura.remove_stacks(removed_stacks)
	if is_player:
		var player_aura := get_player_aura(debuff_name)
		if !player_aura:
			return
		player_aura.remove_stacks(removed_stacks)


func has_debuff(debuff_name : String) -> bool:
	var aura := get_aura(debuff_name)
	if !aura:
		return false
	return true


func get_debuff_stacks(debuff_name : String) -> int:
	var aura := get_aura(debuff_name)
	if !aura:
		return 0
	return aura.get_stacks()


# Looks through member aura containers and returns first instance of debuff by name.
func get_aura(debuff_name: String) -> Debuff:
	var auras : Array = aura_container.get_children()
	for aura : Node in auras:
		if aura is Debuff and aura.debuff_name == debuff_name:
			return aura
	return null


func get_player_aura(debuff_name : String) -> Debuff:
	var player_debuffs : Array = player_debuff_container.get_children()
	for player_debuff : Node in player_debuffs:
		if player_debuff is Debuff and player_debuff.debuff_name == debuff_name:
			return player_debuff
	return null


func _on_h_box_container_gui_input(event: InputEvent) -> void:
	if Global.is_moving_ui:
		return
	if event is InputEventMouseButton: 
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			GameEvents.emit_toggle_focus(_role_key)
