extends Node2D
class_name EnemyManager

signal update_score(amount: int)
signal enemy_defeated(enemy: Enemy, cause: StringName, remaining: int)
signal all_enemies_defeated

@export var enemy_scene: PackedScene = preload("res://scenes/Enemy/enemy.tscn")
@export var spawn_root: Node
@export var enemy_container: Node

var alive_enemies: Array[Enemy] = []

func _ready() -> void:
	if enemy_container == null:
		enemy_container = self
	if spawn_root == null:
		push_warning("EnemyManager: spawn root is not set.")
		return
	for point in spawn_root.get_spawn_points():
		_spawn(point)

func _spawn(point: EnemySpawnPoint) -> void:
	var enemy: Enemy = enemy_scene.instantiate()
	enemy.data = point.enemy_data
	enemy_container.add_child(enemy)
	enemy.global_position = point.global_position
	enemy.defeated.connect(_on_enemy_defeated)
	alive_enemies.append(enemy)
	
func _on_enemy_defeated(enemy: Enemy, cause: StringName) -> void:
	alive_enemies.erase(enemy)
	update_score.emit(1)
	
	enemy_defeated.emit(enemy, cause, alive_enemies.size())
	if alive_enemies.is_empty():
		all_enemies_defeated.emit()
		
func all_settled() -> bool:
	for enemy in alive_enemies:
		if is_instance_valid(enemy) and not enemy.is_settled():
			return false
	return true
	
func wait_until_settled() -> void:
	while not all_settled():
		await get_tree().physics_frame
