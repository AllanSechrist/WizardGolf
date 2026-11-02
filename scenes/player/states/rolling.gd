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
	print("shot_curve ", player.shot_curve, " active_curve: ", player.active_curve)
	
func physics_update(_delta: float) -> void:
	if not player:
		return
	
	player.velocity = player.step_velocity(player.velocity, player.active_curve, _delta)
	
	var collision := player.move_and_collide(player.velocity * _delta)
	if collision:
		player.velocity = player.velocity.bounce(collision.get_normal()) * player.bounciness
		player.active_curve *= player.curve_kept_on_bounce
		
	if player.velocity.length() < player.stop_speed:
		player.velocity = Vector2.ZERO
		stopped.emit()
		
func unhandled_event(_event: InputEvent) -> void:
	if _event.is_action_pressed("cast") and player.spell:
		cast_pressed.emit()
		player.cast_spell()
