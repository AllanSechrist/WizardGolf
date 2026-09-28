extends Spell
class_name StoneFoot

@export var shake_strength := 4.0
@export var shake_duration := 0.2

func cast(player: Player) -> void:
	player.velocity = Vector2.ZERO
	play_effect(player)
	finished.emit()

func play_effect(player: Player) -> void:
	Effects.shake(shake_strength, shake_duration)
