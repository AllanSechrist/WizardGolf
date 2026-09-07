extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.x = 0.0
	player.trajectory_preview.visible = true
	# TODO Animation player transition
	
func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * _delta
	player.move_and_slide()
	
	if Input.is_action_just_pressed("explode"):
		finished.emit(AIRBORNE)
