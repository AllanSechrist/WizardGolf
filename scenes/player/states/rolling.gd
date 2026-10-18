extends State
class_name PlayerRollingState

var player: PlayerCharacter

signal cast_pressed
signal stopped

func enter() -> void:
	player = actor as PlayerCharacter
	player.trajectory_preview.visible = false
	player.wand.visible = false
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
	if not player:
		return
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * _delta)
	
	var motion = player.velocity * _delta
	var collision = player.move_and_collide(motion)
	
	if collision:
		player.velocity = player.velocity.bounce(collision.get_normal()) * player.bounciness
		
	if player.velocity == Vector2.ZERO:
		stopped.emit()
		
func unhandled_event(_event: InputEvent) -> void:
	if _event.is_action_pressed("cast") and player.spell:
		cast_pressed.emit()
		player.cast_spell()
		
func exit() -> void:
	if !Effects.is_time_slow:
		player.end_turn()
