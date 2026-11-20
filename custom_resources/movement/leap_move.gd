extends MoveStyle
class_name LeapMove

@export var max_distance := 160.0
@export var min_distance := 0.0
@export var leap_duration := 0.45
@export var stomp_radius := 8.0
@export var knockback_radius := 32.0
@export var knockback_strength := 250.0

func get_shot_state() -> GDScript:
	return PlayerLeapingState
