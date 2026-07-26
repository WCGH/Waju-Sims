# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends P6Sequence

@onready var aa_1_anim: AnimationPlayer = %AA1Anim
@onready var boss_hp_warn: Label = %BossHPWarn

@onready var pc_positions := {
	"aa": {"lp1": Vector2(0, -9), "lp2": Vector2(0, 9)}
}


# Needed to avoid duplicate ready calls in parent.
func _ready() -> void:
	pass


func start_sub_sequence() -> void:
	aa_1_anim.play("aa1")


# 0:21.5 - Start AA cast (+anim), move to lp stacks, put up a random hp tether
func aa1_cast() -> void:
	target_cast_bar.cast("Akh Afah", 7.75, nid)
	target_cast_bar.cast("Akh Afah", 7.75, hra)
	enemy_cast_bar.start_cast_bar_1("Akh Afah", 7.75)
	enemy_cast_bar.start_cast_bar_2("Akh Afah", 7.75)
	# Start casting animations
	nid.start_up_cast()
	hra.start_up_cast()
	# Random tether
	var rnd := randi_range(0, 2)
	if rnd == 0:
		tether_controller.spawn_tether(nid, hra, Color.PURPLE)
	elif rnd == 1:
		tether_controller.spawn_tether(nid, hra, Color.LIGHT_BLUE)


# 24.0 - Move to LP stacks
func move_to_lp_stacks() -> void:
	for key: String in party:
		if key.right(1) == "1":
			party[key].move_to(pc_positions["aa"]["lp1"])
		else:
			party[key].move_to(pc_positions["aa"]["lp2"])


# 0:27.0 - Remove hp tether
func remove_tether() -> void:
	tether_controller.remove_all_tethers()
	boss_hp_warn.visible = false


# 0:29.25 - AA Hit (+anim)
func aa1_hit() -> void:
	ground_aoe_controller.spawn_circle(v2(party["h1"].global_position),
		AA_RADIUS, 0.3, Color.LIGHT_YELLOW, [4, 4, "Akh Afah"])
	ground_aoe_controller.spawn_circle(v2(party["h2"].global_position),
		AA_RADIUS, 0.3, Color.LIGHT_YELLOW, [4, 4, "Akh Afah"])


func finish_breath_animation() -> void:
	hra.finish_cast()
	nid.finish_cast()


func end_of_sub_sequence() -> void:
	play_sequence("wings1")
