class_name ThrowAbility
extends Node2D

signal throw_started(enemy: Enemy, pocket: Pocket)
signal throw_finished

@export_group("Range")
@export var grab_radius := 48.0      # applied to GrabArea's CircleShape2D
@export var pocket_radius := 200.0   # applied to PocketArea's CircleShape2D

@export_group("Throw")
@export var hold_distance := 20.0    # where the enemy sits in front of the player
@export var pull_time := 0.15        # real seconds (ignores time scale)
@export var overshoot := 1.15        # >1 so the enemy reaches the pocket, not stops at its edge

@export_group("Slow Motion")
@export var slow_scale := 0.1        # 0.0 = full stop
@export var slow_in_time := 0.08     # real seconds to ease into slow-mo
@export var speed_up_time := 0.25    # real seconds to ease back to normal

@onready var player := get_parent() as PlayerCharacter
@onready var grab_area: Area2D = $GrabArea
@onready var pocket_area: Area2D = $PocketArea
@onready var grab_shape: CollisionShape2D = $GrabArea/CollisionShape2D
@onready var pocket_shape: CollisionShape2D = $PocketArea/CollisionShape2D

var is_throwing := false
var _time_tween: Tween

func _ready() -> void:
	# Each character gets its own shapes, so changing one radius doesn't change everyone's.
	grab_shape.shape = grab_shape.shape.duplicate()
	pocket_shape.shape = pocket_shape.shape.duplicate()
	set_radii(grab_radius, pocket_radius)

# Call from PlayerCharacter._apply_data() if radii come from CharacterData.
func set_radii(grab: float, pocket: float) -> void:
	grab_radius = grab
	pocket_radius = pocket
	(grab_shape.shape as CircleShape2D).radius = grab
	(pocket_shape.shape as CircleShape2D).radius = pocket

# --- Public API ---

func can_throw() -> bool:
	return not is_throwing and not find_targets().is_empty()

func throw() -> bool:
	if is_throwing:
		return false
	var targets := find_targets()
	if targets.is_empty():
		return false

	var enemy: Enemy = targets.enemy
	var pocket: Pocket = targets.pocket
	is_throwing = true

	enemy.grab()
	enemy.hold_ended.connect(_on_hold_ended, CONNECT_ONE_SHOT)
	_set_time_scale(slow_scale, slow_in_time)

	var start := enemy.global_position
	var follow := func(t: float) -> void:
		enemy.global_position = start.lerp(_hold_point(pocket), t)

	var tween := enemy.create_tween().set_ignore_time_scale(true)
	enemy.hold_tween = tween
	tween.tween_method(follow, 0.0, 1.0, pull_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_launch.bind(enemy, pocket))

	throw_started.emit(enemy, pocket)
	return true

# Returns {enemy, pocket} or an empty Dictionary if either is missing.
func find_targets() -> Dictionary:
	var enemy := _nearest(grab_area.get_overlapping_bodies()) as Enemy
	if enemy == null:
		return {}
	var pocket := _nearest(pocket_area.get_overlapping_areas()) as Pocket
	if pocket == null:
		return {}
	if player.global_position.distance_to(pocket.global_position) <= hold_distance:
		return {}  # pocket is basically under the player; no line to throw along
	return {"enemy": enemy, "pocket": pocket}

# --- Internals ---

func _direction(pocket: Pocket) -> Vector2:
	return (pocket.global_position - player.global_position).normalized()

func _hold_point(pocket: Pocket) -> Vector2:
	return player.global_position + _direction(pocket) * hold_distance

func _launch(enemy: Enemy, pocket: Pocket) -> void:
	var dir := _direction(pocket)
	enemy.global_position = player.global_position + dir * hold_distance
	var dist := enemy.global_position.distance_to(pocket.global_position)
	var speed := sqrt(2.0 * enemy.friction * dist) * overshoot
	enemy.release(dir * speed)  # emits hold_ended

# Fires on launch, or if the enemy got pulled across a pocket mid-throw.
func _on_hold_ended() -> void:
	is_throwing = false
	_set_time_scale(1.0, speed_up_time)
	throw_finished.emit()

func _set_time_scale(target: float, duration: float) -> void:
	if _time_tween and _time_tween.is_valid():
		_time_tween.kill()
	_time_tween = get_tree().create_tween().set_ignore_time_scale(true)
	_time_tween.tween_property(Engine, "time_scale", target, duration)

func _nearest(nodes: Array) -> Node2D:
	var best: Node2D = null
	var best_d := INF
	for n in nodes:
		if n is Enemy:
			if not n.can_be_grabbed():
				continue
		elif not n is Pocket:
			continue  # ignore stray areas/bodies (e.g. enemy Hitboxes)
		var d := player.global_position.distance_squared_to(n.global_position)
		if d < best_d:
			best_d = d
			best = n
	return best
