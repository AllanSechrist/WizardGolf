extends Spell
class_name FireBall

func cast(character: PlayerCharacter) -> void:
	super(character)
	if player.velocity.is_zero_approx():
		return # no motion
	player.velocity = player.velocity.normalized() * player.full_power_shot
	play_effect()
	finished.emit()
