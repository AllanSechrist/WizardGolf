extends CharacterData
class_name WarriorData

@export_category("Leap")
@export var max_distance := 160.0
@export var min_distance := 0.0
@export var leap_duration := 0.45

func get_shot_state() -> GDScript:
	return PlayerLeapingState
