extends Node
class_name EnemyManager

@onready var enemy_spawns: Node = $"../EnemySpawns"

var enemy_scene := preload("res://scenes/Enemy/enemy.tscn")

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
	print(enemies)

func _on_last_enemy() -> void:
	# TODO
	if enemies.size() == 1:
		final_enemy.emit(enemies.pop_front())
	else:
		print("enemy array is not 1 it is %d" % enemies.size())
	
	# transition camera from player to enemy (signal to game manager)
	# transition camera back to player (signal to game manager)

func _on_defeat(enemy: Enemy) -> void:
	update_score.emit(1)
	enemies.erase(enemy) # remove from Array
	print(enemies) #DEBUG
	
	if enemies.size() <= 1:
		_on_last_enemy()
	
	enemy.die()
