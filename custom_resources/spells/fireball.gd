extends Spell
class_name FireBall

func cast(player: Player) -> void:
	if player.velocity.is_zero_approx():
		return # no motion
	player.velocity = player.velocity.normalized() * player.full_power_shot
	# TODO: Animation Stuff
	finished.emit()
