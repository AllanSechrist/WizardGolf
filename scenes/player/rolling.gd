extends PlayerState

func enter(previous_state_path: String, data := {}) -> void:
	player.trigger_explosion()
	player.trajectory_preview.visible = false
	#TODO Animation player update
	
#func physics_update(_delta: float) -> void:
	##player.velocity.y += player.gravity * _delta
	#player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * _delta)
	#player.move_and_slide()
	#
	#if player.get_slide_collision_count() > 0:
		#var collision = player.get_last_slide_collision()
		#player.velocity = player.velocity.bounce(collision.get_normal()) * player.bounciness
	#
	#if player.velocity == Vector2.ZERO:
		#finished.emit(GROUNDED)

func physics_update(_delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * _delta)
	
	var motion = player.velocity * _delta
	var collision = player.move_and_collide(motion)
	
	if collision:
		player.velocity = player.velocity.bounce(collision.get_normal()) * player.bounciness
		
	if player.velocity == Vector2.ZERO:
		finished.emit(GROUNDED)
