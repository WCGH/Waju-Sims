# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends GroundMarker
class_name Twister


func set_parameters(new_position: Vector3, lifetime: float, fail_conditions: Array) -> void:
	set_center_position(new_position)
	set_lifetime(lifetime)
	set_fail_conditions(fail_conditions)


func _on_body_entered(body: CharacterBody3D) -> void:
	check_fail_twister([body])
	queue_free()


func check_fail_twister(fail_bodies: Array) -> void:
	# Too few hit fail condition
	if min_hit > 0 and fail_bodies.size() < min_hit:
		fail_list.add_fail("Not enough targets hit by %s." % spell_name)
		return
	var fail_bodies_list := []
	# Too many hit fail condition
	if max_hit < 99 and fail_bodies.size() > max_hit:
		for body: CharacterBody3D in fail_bodies:
			if whitelist.has(body):
				continue
			fail_bodies_list.append(body)
	# Blacklist fail condition
	if blacklist.size() > 0:
		for body: CharacterBody3D in fail_bodies:
			if blacklist.has(body):
				fail_bodies_list.append(body)
	# Output fails
	if fail_bodies_list.size() == 1:
		fail_list.add_fail("%s was hit by %s." % [fail_bodies_list[0].name, spell_name])
		return
	if fail_bodies_list.size() > 1:
		fail_list.add_fail("Multiple targets were hit by %s." % spell_name)
		return
