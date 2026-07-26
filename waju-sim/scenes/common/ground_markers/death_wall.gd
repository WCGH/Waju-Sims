# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node3D

@onready var deathwall_trigger: Area3D = %DeathwallTrigger
@onready var fail_list: FailList = get_tree().get_first_node_in_group("fail_list")


func _on_deathwall_trigger_body_exited(body: CharacterBody3D) -> void:
	if is_instance_valid(body):
		fail_list.add_fail("%s hit deathwall." % body.name)
