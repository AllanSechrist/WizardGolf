extends Node2D
class_name EnemySpawnGroup

func get_spawn_points() -> Array[EnemySpawnPoint]:
	var points: Array[EnemySpawnPoint] = []
	for child in get_children():
		if child is EnemySpawnPoint:
			points.append(child)
	return points
