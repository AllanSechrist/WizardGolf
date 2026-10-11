extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.trajectory_preview.visible = true
	
func physics_update(_delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * _delta)
	
	var motion = player.velocity * _delta
	var collision = player.move_and_collide(motion)
	
	if collision:
		player.velocity = player.velocity.bounce(collision.get_normal()) * player.bounciness
		
	if player.velocity == Vector2.ZERO:
		finished.emit(GROUNDED)
		return
		
	if !Effects.is_time_slow:
		finished.emit(ROLLING)
		return
	
func handle_input(event: InputEvent) -> void:
	if event.is_action_pressed("explode"):
		player.spell.spell_action(player)
		Effects.end_time_slow()
		player.trajectory_preview.visible = false

func exit() -> void:
	player.hide_power_meter()
