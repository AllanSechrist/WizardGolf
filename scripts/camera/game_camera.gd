extends Camera2D
class_name GameCamera

enum Mode { FOLLOW, PAN, FREE }

@export_group("Follow")
@export var target: Node2D
@export var follow_offset := Vector2.ZERO 
@export var follow_speed := 6.0
@export var look_ahead := 0.2
@export var max_look_ahead := 48.0

@export_group("Free Look")
@export var return_when_target_moves := true
@export var moving_threshold := 20.0

@export_group("Bounds")
@export var bounds_source: Node2D
@export var bounds_margin := 32.0

var mode := Mode.FOLLOW
var is_dragging := false

var _bounds := Rect2()
var _has_bounds := false
var _target_was_moving := false

var shake_tween: Tween
var _pan_tween: Tween

signal pan_finished

func _ready() -> void:
	Effects.camera = self
	make_current()
	position_smoothing_enabled = false
	refresh_bounds()
	if target:
		snap_to_target()
# --------- PUBLIC ------------------		
func follow(new_target: Node2D, pan_time := 0.0) -> void:
	target = new_target
	_target_was_moving = false
	_kill_pan()
	
	if target == null or pan_time <= 0.0:
		mode = Mode.FOLLOW
		return
		
	mode = Mode.PAN
	_pan_tween = create_tween()
	_pan_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_pan_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pan_tween.tween_property(self, "global_position", _clamp_to_bounds(_follow_point()), pan_time)
	_pan_tween.finished.connect(_on_pan_finished)
	
func snap_to_target() -> void:
	if target:
		global_position = _clamp_to_bounds(_follow_point())
		
func recenter() -> void:
	mode = Mode.FOLLOW

func shake(strength: float = 4.0, duration: float = 0.2, shakes: int = 6) -> void:
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
		
	shake_tween = create_tween()
	var step := duration / shakes
	
	for i in shakes:
		var falloff := 1.0 - float(i) /shakes
		var shake_target := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff
		shake_tween.tween_property(self, "offset", shake_target, step)
		
	shake_tween.tween_property(self, "offset", Vector2.ZERO, step)

func refresh_bounds() -> void:
	var src = bounds_source
	if src == null or not src.has_method("get_used_rect"):
		_has_bounds = false
		return
	var cells: Rect2i = src.get_used_rect()
	var tile_size := Vector2(src.tile_set.tile_size)
	var top_left: Vector2 = src.to_global(Vector2(cells.position) * tile_size)
	var bottom_right: Vector2 = src.to_global(Vector2(cells.end) * tile_size)
	_bounds = Rect2(top_left, bottom_right - top_left)
	_has_bounds = true
	
# ----------- INPUT -------------

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("camera_pan"):
		is_dragging = true
		mode = Mode.FREE
		get_viewport().set_input_as_handled()
	elif event.is_action_released("camera_pan"):
		is_dragging = false
		get_viewport().set_input_as_handled()
	elif event is InputEventMouseMotion and is_dragging:
		global_position -= event.relative / zoom
		global_position = _clamp_to_bounds(global_position)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("camera_recenter"):
		recenter()

# ---------- UPDATE -----------

func _process(delta: float) -> void:
	var body := target as CharacterBody2D
	
	if body:
		var moving := body.velocity.length() > moving_threshold
		if return_when_target_moves and mode == Mode.FREE and moving and not _target_was_moving and not is_dragging:
			mode = Mode.FOLLOW
		_target_was_moving = moving
		
	if mode == Mode.FOLLOW and target:
		global_position = global_position.lerp(_follow_point(), 1.0 - exp(-follow_speed * delta))
		
	global_position = _clamp_to_bounds(global_position)
	
func _follow_point() -> Vector2:
	var point := target.global_position + follow_offset
	var body := target as CharacterBody2D
	if body:
		point += (body.velocity * look_ahead).limit_length(max_look_ahead)
	return point
	
func _on_pan_finished() -> void:
	if mode == Mode.PAN:
		mode = Mode.FOLLOW
	pan_finished.emit()
	
func _kill_pan() -> void:
	if _pan_tween and _pan_tween.is_valid():
		_pan_tween.kill()
	_pan_tween = null
	
func _clamp_to_bounds(p: Vector2) -> Vector2:
	if not _has_bounds:
		return p
	var half_view := get_viewport_rect().size / zoom * 0.5
	var r := _bounds.grow(bounds_margin)
	var min_p := r.position + half_view
	var max_p := r.end - half_view
	var center := r.get_center()
	return Vector2(
		clampf(p.x, min_p.x, max_p.x) if min_p.x <= max_p.x else center.x,
		clampf(p.y, min_p.y, max_p.y) if min_p.y <= max_p.y else center.y
	)
