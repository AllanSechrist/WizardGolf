extends Area2D
class_name Enemy

signal defeat(Enemy)

@export var data: EnemyData
@onready var sprite_2d: Sprite2D = $Sprite2D

var is_goal := false

func _ready() -> void:
	if data:
		sprite_2d.texture = data.sprite

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		defeat.emit(self)
		
func become_goal() -> void:
	is_goal = true
	# Animation stuff?

func die() -> void:
	queue_free()
