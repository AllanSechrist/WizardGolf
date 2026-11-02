extends Node2D
class_name TrajectoryPreview

@export var player: PlayerCharacter
@export_range(0.0, 1.0, 0.01) var preview_length_ratio := 0.25
@export var dot_spacing := 12.0
@export var dot_radius := 2.0
@export var dot_color := Color(1, 1, 1, 0.6)
@export var collision_mask := 1
@export var max_sim_steps := 600
@export var max_bounces := 1

func _process(_delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	for point in simulate_trajectory():
		draw_circle(to_local(point), dot_radius, dot_color)
		
func simulate_trajectory() -> Array[Vector2]:
	var pos := player.global_position
	var dir := player.get_launch_direction()
	var vel := dir * player.full_power_shot # always previews a full charge
	var curve := player.shot_curve * player.get_curve_sign(dir)
	var dt := 1.0 / Engine.physics_ticks_per_second # same step size as Rolling

	var full_distance: float = (player.full_power_shot ** 2) / (2.0 * maxf(player.friction, 0.0001))
	var preview_distance := full_distance * preview_length_ratio

	var space_state := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.new()
	query.collision_mask = collision_mask
	query.exclude = [player.get_rid()]

	var points: Array[Vector2] = []
	var travelled := 0.0
	var since_dot := 0.0
	var bounces := 0

	for i in max_sim_steps:
		vel = player.step_velocity(vel, curve, dt)
		if vel.length() < player.stop_speed or travelled >= preview_distance:
			break

		query.from = pos
		query.to = pos + vel * dt
		var hit := space_state.intersect_ray(query)

		if hit:
			travelled += pos.distance_to(hit.position)
			pos = hit.position
			points.append(pos) # mark the bounce point
			if bounces >= max_bounces:
				break
			bounces += 1
			vel = vel.bounce(hit.normal) * player.bounciness
			curve *= player.curve_kept_on_bounce
			pos += hit.normal * 0.5 # nudge off the wall
			since_dot = 0.0
			continue

		var moved := pos.distance_to(query.to)
		pos = query.to
		travelled += moved
		since_dot += moved
		if since_dot >= dot_spacing:
			since_dot -= dot_spacing
			points.append(pos)

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
