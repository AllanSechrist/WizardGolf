extends Node

var camera: Camera2D
var time_tween: Tween
var is_time_slow := false

# ------------ SHAKE
func shake(strength: float = 4.0, duration: float = 0.2) -> void:
	if camera:
		camera.shake(strength, duration)

# ------------ SLOW TIME
func slow_time(scale: float = 0.3, duration: float = 0.5, recover: float = 0.2) -> void:
	if time_tween and time_tween.is_running():
		time_tween.kill()

	is_time_slow = true
	Engine.time_scale = scale
	
	time_tween = create_tween()
	time_tween.finished.connect(end_time_slow)
	time_tween.set_ignore_time_scale(true)
	time_tween.tween_interval(duration)
	time_tween.tween_method(_set_time_scale, scale, 1.0, recover)
	
func _set_time_scale(value: float) -> void:
	Engine.time_scale = value

func end_time_slow() -> void:
	if time_tween and time_tween.is_running():
		time_tween.kill()
	
	is_time_slow = false
	Engine.time_scale = 1.0
# ------------ SPAWN
func spawn(scene: PackedScene, pos: Vector2, parent: Node = null) -> Node2D:
	var fx := scene.instantiate() as Node2D
	if parent:
		parent.add_child(fx)
		fx.position = Vector2.ZERO
	else:
		get_tree().current_scene.add_child(fx)
		fx.global_position = pos
	return fx
