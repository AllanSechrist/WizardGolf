extends Node
class_name EnemyManager

@onready var enemy_spawns: Node = $"../EnemySpawns"

var enemy_scene := preload("res://scenes/Enemy/enemy.tscn")

signal update_score(int)

var enemies: Array

func _ready() -> void:
	for spawn_point in enemy_spawns.get_children():
		var enemy = enemy_scene.instantiate()
		enemy.data = spawn_point.enemy_data
		enemy.global_position = spawn_point.global_position
		add_child(enemy)
		enemy.defeat.connect(_on_defeat)
		
	enemies = get_children()
	print(enemies)

func _on_last_enemy() -> void:
	# TODO
	# get final enemy from array
	# transition camera from player to enemy (signal to game manager)
	# transformation animation / replace with golf hole scene.
	# transition camera back to player (signal to game manager)
	print("Last Enemy!")

func _on_defeat(enemy: Enemy) -> void:
	update_score.emit(1)
	enemies.erase(enemy) # remove from Array
	print(enemies) #DEBUG
	
	if enemies.size() <= 1:
		_on_last_enemy()
	
	enemy.die()
