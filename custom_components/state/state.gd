extends RefCounted
class_name State

var actor: Node

func enter() -> void:
	pass
	
func exit() -> void:
	pass
	
func update(_delta:float) -> void:
	pass
	
func physics_update(_delta: float) -> void:
	pass

func unhandled_event(_event: InputEvent) -> void:
	pass
