# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name EncounterControllerDSR

#@export var chain_sequences := false

@onready var sequences := get_children()

var am_index := 0

func start_encounter(party: Dictionary) -> void:
	#var selected_sequence := Global.selected_sequence_index
	var selected_sequence := 0
	print("Starting sequence: ", sequences[selected_sequence])
	#if chain_sequences:
		#sequences[selected_sequence].start_sequence(party).connect(play_next_sequence)
	sequences[selected_sequence].start_sequence(party)


#func play_next_sequence(party: Dictionary, seq_index: int) -> void:
	#if seq_index != -1:
		#sequences[seq_index].start_sequence(party).connect(play_next_sequence)
