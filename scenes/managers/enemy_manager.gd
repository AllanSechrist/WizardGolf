extends Node
class_name EnemyManager

@onready var enemy_spawns: Node = $"../EnemySpawns"

var enemy_scene := preload("res://scenes/Enemy/enemy.tscn")
var hole_scene := preload("res://scenes/hole/hole.tscn")

signal update_score(int)
signal final_enemy(enemy: Enemy)

var enemies: Array

func _ready() -> void:
	for spawn_point in enemy_spawns.get_children():
		var enemy = enemy_scene.instantiate()
		enemy.data = spawn_point.enemy_data
		enemy.global_position = spawn_point.global_position
		add_child(enemy)
		enemy.defeat.connect(_on_defeat)
		
	enemies = get_children()

func _on_defeat(enemy: Enemy) -> void:
	update_score.emit(1)
	enemies.erase(enemy) # remove from Array
	enemy.die()
	if enemies.size() == 1:
		final_enemy.emit(enemies[0])

func turn_into_hole(enemy: Enemy) -> Area2D:
	var hole: Hole = hole_scene.instantiate()
	enemy.get_parent().add_child(hole)
	hole.global_position = enemy.global_position
	enemies.erase(enemy)
	enemy.die()
	return hole
