extends Area2D
class_name Enemy


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		queue_free()
