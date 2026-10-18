extends State
class_name PlayerCastingState

var player: PlayerCharacter

signal stopped
signal cast_pressed

func enter() -> void:
	#player.spell.play_effect()
	player = actor as PlayerCharacter
	
func physics_update(_delta: float) -> void:
	player.velocity = player.velocity.move_toward(Vector2.ZERO, player.friction * _delta)
	
	var motion = player.velocity * _delta
	var collision = player.move_and_collide(motion)
	
	if collision:
		player.velocity = player.velocity.bounce(collision.get_normal()) * player.bounciness
		
	if player.velocity == Vector2.ZERO:
		stopped.emit()
		return
		
	if !Effects.is_time_slow:
		cast_pressed.emit()
		return
	
func unhandled_event(event: InputEvent) -> void:
	if event.is_action_pressed("shoot") and Effects.is_time_slow:
		player.spell.spell_action()
		Effects.end_time_slow()
		

func exit() -> void:
	player.hide_power_meter()
