extends State
class_name PlayerChargingState

var player: PlayerCharacter

signal shoot_pressed

func enter() -> void:
	player = actor as PlayerCharacter
	player.wand.visible = false
	player.start_power_meter()
	
func physics_update(delta: float) -> void:
	player.update_power_meter(delta)
	
func unhandled_event(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot_pressed.emit()

func exit() -> void:
	player.hide_power_meter()
