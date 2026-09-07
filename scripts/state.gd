extends Node
class_name State

signal finished(next_state_path: String, data: Dictionary)

func handle_input(_event: InputEvent) -> void:
	pass
	
func update(_delta: float) -> void:
	pass
	
func _physics_update(_delta: float) -> void:
	pass
	
func enter(previos_state_path: String, data := {}) -> void:
	pass
	
func exit() -> void:
	pass
