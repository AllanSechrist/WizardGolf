extends Spell
class_name StoneFoot

@export var shake_strength := 4.0
@export var shake_duration := 0.2

func cast(character: PlayerCharacter) -> void:
	player = character
	player.velocity = Vector2.ZERO
	play_effect()
	finished.emit()

func play_effect() -> void:
	Effects.shake(shake_strength, shake_duration)
