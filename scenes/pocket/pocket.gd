extends Area2D
class_name Pocket

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("pockets")
	
func _on_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.fall_into_pocket(self)
