extends State
class_name PlayerLeapingState

@export var shake_strength := 4.0
@export var shake_duration := 0.2

const LANDING_STEP := 4.0
const ENEMY_MASK := 1 << 2

var player: PlayerCharacter
var _saved_layer: int

signal stopped

func enter() -> void:
	player = actor as PlayerCharacter
	var leap = _get_leap_settings()
	var dir := player.direction_snapshot
	player.direction_snapshot = Vector2.ZERO
	var distance := lerpf(leap.min_distance, leap.max_distance, player.shot_power)
	
	var start := player.global_position
	var target := _find_landing(start, start + dir * distance)
	
	
	player.velocity = Vector2.ZERO
	_saved_layer = player.collision_layer
	player.collision_layer = 0
	
	#var windup_point := start.lerp(target, 0.3)
	#var windup_time = leap.leap_duration * 0.6
	#var dash_time = leap.leap_duration * 0.4
	
	var tween := player.create_tween()
	tween.tween_property(player, "global_position", target, leap.leap_duration).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	tween.finished.connect(_on_landed)
	
	#var tween := player.create_tween()
	#tween.tween_property(player, "global_position", windup_point, windup_time) \
		#.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	#tween.tween_property(player, "global_position", target, dash_time) \
		#.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	#tween.finished.connect(_on_landed)

func _on_landed() -> void:
	_resolve_landing()
	player.collision_layer = _saved_layer
	Effects.shake(shake_strength, shake_duration)
	stopped.emit()

func _resolve_landing() -> void:
	var leap = _get_leap_settings()
	var center := player.global_position

	for enemy in _get_enemies_in_radius(center, leap.knockback_radius):
		var offset := enemy.global_position - center
		if offset.length() <= leap.stomp_radius:
			enemy.die(&"stomp")
		else:
			enemy.knock(offset.normalized() * leap.knockback_strength)

func _get_enemies_in_radius(center: Vector2, radius: float) -> Array[Enemy]:
	var circle := CircleShape2D.new()
	circle.radius = radius

	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = circle
	query.transform = Transform2D(0.0, center)
	query.collision_mask = ENEMY_MASK
	query.collide_with_areas = false

	var enemies: Array[Enemy] = []
	for hit in player.get_world_2d().direct_space_state.intersect_shape(query, 16):
		var enemy := hit.collider as Enemy
		if enemy:
			enemies.append(enemy)
	return enemies

func _find_landing(start: Vector2, target: Vector2) -> Vector2:
	var shape_node: CollisionShape2D = player.get_node("CollisionShape2D")
	var space := player.get_world_2d().direct_space_state
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape_node.shape
	query.collision_mask = player.collision_mask
	query.exclude = [player.get_rid()]
	
	var offset := target - start
	var dist := offset.length()
	if is_zero_approx(dist):
		return start
	var dir := offset / dist
	
	while dist > 0.0:
		var pos := start + dir * dist
		query.transform = Transform2D(0.0, pos + shape_node.position)
		if space.intersect_shape(query, 1).is_empty():
			return pos
		dist -= LANDING_STEP
	return start
	
func _get_leap_settings():
	return player.data.move_style
