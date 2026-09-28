extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.start_power_meter()
	
func physics_update(delta: float) -> void:
	player.update_power_meter(delta)
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("explode"):
		finished.emit(ROLLING)

func exit() -> void:
	player.hide_power_meter()
