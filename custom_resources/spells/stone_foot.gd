extends Spell
class_name StoneFoot

func cast(player: Player) -> void:
	player.velocity = Vector2.ZERO
	#TODO: Animation Stuff
	finished.emit()
