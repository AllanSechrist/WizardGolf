extends State
class_name PlayerGroundedState

var player: PlayerCharacter

signal shoot_pressed

func enter() -> void:
	player = actor as PlayerCharacter
	player.velocity.x = 0.0
	player.trajectory_preview.visible = true
	player.turn_start()
	
func physics_update(_delta: float) -> void:
	if not player:
		return
		
	player.move_and_slide()
	
	#if Input.is_action_just_pressed("explode"):
		#pass
		
func unhandled_event(event: InputEvent) -> void:
	if event.is_action_pressed("shoot"):
		shoot_pressed.emit()
