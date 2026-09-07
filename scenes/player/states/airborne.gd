extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.trigger_explosion()
	#TODO Animation player update
	
func physics_update(_delta: float) -> void:
	player.velocity.y += player.gravity * _delta
	player.move_and_slide()
	
	if player.is_on_floor():
		finished.emit(GROUNDED)
