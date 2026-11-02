extends State
class_name PlayerAimingState

var player: PlayerCharacter

signal shoot_pressed

func enter() -> void:
	player = actor as PlayerCharacter
	player.velocity.x = 0.0
	#player.trajectory_preview.visible = true
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
		pass
