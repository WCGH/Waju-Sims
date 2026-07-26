# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Enemy

var tether: Tether


# TODO: make safer call or load tether resource here.
func activate_tether(target : Node3D) -> void:
	if !$Tether:
		print("Error. Tether not found in Vellguine")
		return
	tether = $Tether
	tether.target = target
	tether.active = true
	tether.visible = true


func remove_tether() -> void:
	tether.visible = false
	tether.active = false
