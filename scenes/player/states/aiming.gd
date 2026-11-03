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
		player.shot_curve = 0.0
	elif event.is_action_pressed("increase_curve"):
		_adjust_curve(1)
	elif event.is_action_pressed("decrease_curve"):
		_adjust_curve(-1)
		
func _adjust_curve(steps: int) -> void:
	var value = player.shot_curve + steps * player.curve_step
	value = snappedf(value, player.curve_step)
	player.shot_curve = clampf(value, -player.max_curve, player.max_curve)
