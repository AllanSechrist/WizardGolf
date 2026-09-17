extends Node
class_name EnemyManager

signal update_score(int)

func _ready() -> void:
	var enemies := get_children()
	for enemy in enemies:
		enemy.defeat.connect(_on_defeat)

func _on_defeat(enemy: Enemy) -> void:
	update_score.emit(1)
	enemy.die()
