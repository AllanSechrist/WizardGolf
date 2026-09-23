extends Area2D
class_name Enemy

signal defeat(enemy: Enemy)

@export var data: EnemyData
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if data:
		sprite_2d.texture = data.sprite

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		defeat.emit(self)

func die() -> void:
	queue_free()
	
func play_transformation() -> void:
	print("Animation!")
	await get_tree().create_timer(1.0, true).timeout
