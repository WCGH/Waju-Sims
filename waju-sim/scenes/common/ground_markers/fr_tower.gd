extends LRTower

class_name FRTower


func play_start_animation() -> void:
	animation_player.play("orb_drop")
	animation_player.animation_finished.connect(on_animation_finished)


# Removes inner ring highlight in parent class.
func check_bodies() -> void:
	if bodies < bodies_required:
		soaked = SoakState.UNDER
	elif bodies == bodies_required:
		soaked = SoakState.SOAKED
	else:
		soaked = SoakState.OVER


func on_animation_finished(anim_name: String):
	if lifetime == -1.0:
		self.show()
		return
	if anim_name == "orb_drop":
		self.queue_free()
