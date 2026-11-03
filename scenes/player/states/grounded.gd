extends State
class_name PlayerGroundedState

var player: PlayerCharacter

signal shoot_pressed

func enter() -> void:
	player = actor as PlayerCharacter
	player.velocity.x = 0.0

func unhandled_event(event: InputEvent) -> void:
	if not player.can_act:
		return
	if event.is_action_pressed("shoot"):
		shoot_pressed.emit()
