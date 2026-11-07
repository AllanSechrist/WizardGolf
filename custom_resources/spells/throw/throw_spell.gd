class_name ThrowSpell
extends Spell

@export_group("Targeting")
@export var grab_radius := 48.0      # how close an enemy must be to the player
@export var pocket_radius := 200.0   # how close a pocket must be to the player

@export_group("Throw")
@export var hold_distance := 20.0    # where the enemy sits in front of the player
@export var pull_time := 0.15        # real seconds (ignores time scale)
@export var overshoot := 1.15        # >1 so the enemy reaches the pocket, not stops at its edge

@export_group("Slow Motion")
@export var slow_scale := 0.1        # 0.0 = full stop
@export var slow_in_time := 0.08     # real seconds to ease into slow-mo
@export var speed_up_time := 0.25    # real seconds to ease back to normal

var _time_tween: Tween

func is_castable(character: PlayerCharacter) -> bool:
	return not _find_targets(character).is_empty()

func cast(character: PlayerCharacter) -> void:
	super.cast(character)

	var targets := _find_targets(character)
	if targets.is_empty():
		finished.emit()
		return

	var enemy: Enemy = targets.enemy
	var pocket: Pocket = targets.pocket
	var tree := character.get_tree()

	play_effect()

	enemy.grab()
	enemy.hold_ended.connect(_on_hold_ended.bind(tree), CONNECT_ONE_SHOT)
	_set_time_scale(tree, slow_scale, slow_in_time)

	var start := enemy.global_position
	var follow := func(t: float) -> void:
		enemy.global_position = start.lerp(_hold_point(character, pocket), t)

	var tween := enemy.create_tween().set_ignore_time_scale(true)
	enemy.hold_tween = tween
	tween.tween_method(follow, 0.0, 1.0, pull_time) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_launch.bind(enemy, character, pocket))


func _find_targets(character: PlayerCharacter) -> Dictionary:
	var tree := character.get_tree()

	var enemy := _nearest(tree.get_nodes_in_group(&"enemies"), character.global_position, grab_radius) as Enemy
	if enemy == null:
		return {}

	var pocket := _nearest(tree.get_nodes_in_group(&"pockets"), character.global_position, pocket_radius) as Pocket
	if pocket == null:
		return {}

	if character.global_position.distance_to(pocket.global_position) <= hold_distance:
		return {}  

	return {"enemy": enemy, "pocket": pocket}

func _direction(character: PlayerCharacter, pocket: Pocket) -> Vector2:
	return (pocket.global_position - character.global_position).normalized()

func _hold_point(character: PlayerCharacter, pocket: Pocket) -> Vector2:
	return character.global_position + _direction(character, pocket) * hold_distance

func _launch(enemy: Enemy, character: PlayerCharacter, pocket: Pocket) -> void:
	var dir := _direction(character, pocket)
	enemy.global_position = character.global_position + dir * hold_distance
	var dist := enemy.global_position.distance_to(pocket.global_position)
	var speed := sqrt(2.0 * enemy.friction * dist) * overshoot
	enemy.release(dir * speed)  # emits hold_ended


func _on_hold_ended(tree: SceneTree) -> void:
	_set_time_scale(tree, 1.0, speed_up_time)
	finished.emit()

func _set_time_scale(tree: SceneTree, target: float, duration: float) -> void:
	if _time_tween and _time_tween.is_valid():
		_time_tween.kill()
	_time_tween = tree.create_tween().set_ignore_time_scale(true)
	_time_tween.tween_property(Engine, "time_scale", target, duration)

func _nearest(nodes: Array, from: Vector2, radius: float) -> Node2D:
	var best: Node2D = null
	var best_d := radius * radius
	for n in nodes:
		if n is Enemy and not n.can_be_grabbed():
			continue
		var d := from.distance_squared_to(n.global_position)
		if d <= best_d:
			best_d = d
			best = n
	return best
