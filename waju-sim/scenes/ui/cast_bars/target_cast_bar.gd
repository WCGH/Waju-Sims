# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer

class_name TargetCastBar

@export var spell_cast_scene : PackedScene

@onready var label : Label = $MarginContainer/VBoxContainer/Label
@onready var progress_bar : ProgressBar = $MarginContainer/VBoxContainer/ProgressBar
@onready var target_controller: TargetController = get_tree().get_first_node_in_group("target_controller")
@onready var move_ui_bg: Panel = %MoveUIBG

var player : Player
var current_target: Node3D
var current_cast : SpellCast
var active_casts : Array
var casting := false


func _ready() -> void:
	section_key = "cast_bar"
	target_controller.target_changed.connect(on_target_changed)
	GameEvents.ui_ready.connect(on_ui_ready)


func _process(_delta : float) -> void:
	if casting:
		progress_bar.value = 1 - (current_cast.cast_timer.time_left / current_cast.cast_timer.wait_time)
	move_and_save_container()


func init_position():
	GameEvents.toggle_move_ui.connect(on_toggle_move_ui)
	margin_container = $MarginContainer
	move_ui_reset_button  = %MoveUIResetButton
	move_ui_reset_button.reset_position.connect(reset_position)
	load_position_and_scale()



# TODO: return cast finished signal.
func cast(cast_name : String, cast_time : float, caster: Node3D) -> void:
	var new_spell: SpellCast = spell_cast_scene.instantiate()
	new_spell.set_parameters(cast_name, cast_time, caster)
	self.add_child(new_spell)
	new_spell.start_cast().connect(on_cast_finished)
	active_casts.append(new_spell)
	
	if caster == current_target:
		current_cast = new_spell
		update_current_cast()


func update_current_cast() -> void:
	label.text = current_cast.spell_name
	progress_bar.value = 1 - (current_cast.cast_timer.time_left / current_cast.cast_timer.wait_time)
	visible = true
	casting = true



func clear_casts() -> void:
	visible = false
	casting = false
	for i in active_casts.size():
		var scast: SpellCast = active_casts.pop_at(i)
		scast.queue_free()


func on_target_changed(new_target: Node3D) -> void:
	# No target selected
	if new_target == null:
		casting = false
		visible = false
		return
	
	current_target = new_target
	for active_cast: SpellCast in active_casts:
		if active_cast.caster == current_target:
			current_cast = active_cast
			update_current_cast()
			casting = true
			return
	# Target is not casting anything
	casting = false
	visible = false


# TODO: emit signal when cast finished
func on_cast_finished(finished_cast: SpellCast) -> void:
	if finished_cast == current_cast:
		visible = false
		casting = false
		current_cast = null
	active_casts.erase(finished_cast)
	finished_cast.queue_free()


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)



func on_move_ui_on():
	self.show()
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
	if not casting:
		self.hide()


func on_toggle_move_ui(is_moving: bool):
	if is_moving:
		on_move_ui_on()
	else:
		on_mouse_click_up()
		on_move_ui_off()
