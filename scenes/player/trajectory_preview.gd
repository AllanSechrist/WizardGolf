extends Node2D
class_name TrajectoryPreview

@export var player: Player
@export_range(0.0, 1.0, 0.01) var preview_length_ratio := 0.25
@export var dot_spacing := 12.0
@export var dot_radius := 2.0
@export var dot_color := Color(1, 1, 1, 0.6)
@export var collision_mask := 1

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	for point in simulate_trajectory():
		draw_circle(to_local(point), dot_radius, dot_color)
		
func simulate_trajectory() -> Array[Vector2]:
	var pos := player.global_position
	var dir := player.get_launch_direction()
	
	var full_distance = (player.launch_speed ** 2) / (2.0 * max(player.friction, 0.0001))
	var preview_distance = full_distance * preview_length_ratio
	
	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.new()
	query.collision_mask = collision_mask
	query.exclude = [player.get_rid()]
	
	var points: Array[Vector2] = []
	
	query.from = pos
	query.to = pos + dir * preview_distance
	var result := space_state.intersect_ray(query)
	var segment_end: Vector2 = result.position if result else query.to
	
	points.append_array(_dotted_segment(pos, segment_end))
	if result:
		points.append(segment_end)
		
	if not result:
		return points
		
	var bounce_dir: Vector2 = dir.bounce(result.normal)
	var remaining_distance: float = preview_distance - pos.distance_to(segment_end)
	
	query.from = segment_end
	query.to = segment_end + bounce_dir * remaining_distance
	var bounce_result := space_state.intersect_ray(query)
	var bounce_end: Vector2 = bounce_result.position if bounce_result else query.to
	
	points.append_array(_dotted_segment(segment_end, bounce_end))
	if bounce_result:
		points.append(bounce_end)
		
	return points
	
func _dotted_segment(from: Vector2, to: Vector2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	var segment_length := from.distance_to(to)
	if segment_length <= 0.0:
		return points
		
	var dot_count := int(segment_length / dot_spacing)
	for i in range(1, dot_count + 1):
		points.append(from.lerp(to, (i * dot_spacing) / segment_length))
		
	return points
