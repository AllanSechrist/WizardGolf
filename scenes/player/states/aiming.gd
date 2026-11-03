extends State
class_name PlayerAimingState

var player: PlayerCharacter

signal shoot_pressed

func enter() -> void:
	player = actor as PlayerCharacter
	player.velocity.x = 0.0
	player.wand.visible = true
	
func physics_update(_delta: float) -> void:
	if not player:
		return
		
	player.aim()

func unhandled_event(event: InputEvent) -> void:
	if not player.can_act:
		return
	if event.is_action_pressed("shoot"):
		player.snapshot_direction()
		shoot_pressed.emit()
	elif event.is_action_pressed("curve_shot"):
		player.toggle_curve_shot_spell()
	elif event.is_action_pressed("increase_curve"):
		player.adjust_curve(1)
	elif event.is_action_pressed("decrease_curve"):
		player.adjust_curve(-1)
