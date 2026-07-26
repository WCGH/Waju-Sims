# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node
class_name SpellCast

signal cast_complete(cast: SpellCast)

@onready var cast_timer: Timer = %CastTimer

var spell_name := ""
var cast_time := 5.0
var caster: Node3D


func set_parameters(new_spell_name: String, new_cast_time: float, new_caster: Node3D) -> void:
	spell_name = new_spell_name
	cast_time = new_cast_time
	caster = new_caster


func start_cast() -> Signal:
	cast_timer.wait_time = cast_time
	cast_timer.start()
	cast_timer.timeout.connect(on_cast_timer_timeout)
	return cast_complete


func on_cast_timer_timeout() -> void:
	cast_complete.emit(self)
