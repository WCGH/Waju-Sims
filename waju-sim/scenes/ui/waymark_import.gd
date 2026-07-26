# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MarginContainer

const WARN_ENCOUNTER_ID_MISMATCH := "Warning: Encounter ID does not match %s."
const VALID_IMPORT := "Waymarks valid."
const ERR_INVALID_IMPORT := "Invalid import."

@onready var waymark_menu: WaymarkMenu = $".."
@onready var import_text_edit: TextEdit = %ImportTextEdit
@onready var validate_label: Label = %ValidateLabel
@onready var import_button: Button = %ImportButton
@onready var slot_select_button: OptionButton = %SlotSelectButton

var map_ids := {Global.Encounter.FRU: 1006.0, Global.Encounter.DSR: 788.0, Global.Encounter.DMU: 1094.0}
var enc_names := {Global.Encounter.FRU: "FRU", Global.Encounter.DSR: "DSR", Global.Encounter.DMU: "DMU"} 
var import_text: String
var data_received


func _on_import_text_edit_text_changed() -> void:
	validate_text()


func validate_text():
	import_text = import_text_edit.get_text()
	# Retrieve data
	var json = JSON.new()
	var error = json.parse(import_text)
	if error == OK:
		data_received = json.data
		if typeof(data_received) == TYPE_DICTIONARY:
			#print(data_received) # Prints the Dictionary.
			import_button.disabled = false
			check_map_id()
		else:
			print("Unexpected data")
		
	else:
		print("JSON Parse Error: ", json.get_error_message(), " at line ", json.get_error_line())
		import_button.disabled = true
		update_warning_label(ERR_INVALID_IMPORT)


func check_map_id():
	print(data_received["MapID"])
	if data_received["MapID"] == map_ids[Global.encounter]:
		update_warning_label(VALID_IMPORT)
	else:
		update_warning_label(WARN_ENCOUNTER_ID_MISMATCH % enc_names[Global.encounter])


func update_warning_label(warning: String):
	validate_label.set_text(warning)
	if warning == ERR_INVALID_IMPORT:
		validate_label.label_settings.font_color = Color.RED
	elif warning == VALID_IMPORT:
		validate_label.label_settings.font_color = Color.GREEN
	else:
		validate_label.label_settings.font_color = Color.YELLOW


func _on_back_button_pressed() -> void:
	self.hide()


func _on_import_button_pressed() -> void:
	waymark_menu.waymark_controller.import_dict_to_custom(data_received, slot_select_button.selected)
	waymark_menu.set_slot_name(slot_select_button.selected + 3)
	self.hide()
