extends Node2D
class_name TrajectoryPreview

@export var player: Player
@export var max_steps := 40
@export var dot_step_time := 0.04
@export var dot_radius := 2.0
@export var dot_color := Color(1, 1, 1, 0.6)
@export var collision_mask := 1

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	for point in simulate_trajectory():
		draw_circle(to_local(point), dot_radius, dot_color)
		
func simulate_trajectory() -> Array[Vector2]:
	var points: Array[Vector2] = []
	var pos := player.global_position
	var vel := player.get_launch_direction() * player.launch_speed
	
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.new()
	query.collision_mask = collision_mask
	query.exclude = [player.get_rid()]
	
	for i in max_steps:
		vel.y += player.gravity * dot_step_time
		var next_pos := pos + vel * dot_step_time
		
		query.from = pos
		query.to = next_pos
		var result := space_state.intersect_ray(query)
		
		if result:
			points.append(result.position)
			break
		
		points.append(next_pos)
		pos = next_pos
		
	return points
