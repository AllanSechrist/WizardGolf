extends Camera2D
class_name GameCamera

enum Mode { FOLLOW, PAN, FREE, OVERVIEW }

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

@export_group("Overview")  # NEW
@export var start_in_overview := false
@export var overview_time := 0.4
@export var pixel_perfect_overview := false

var mode := Mode.FOLLOW
var is_dragging := false

var _bounds := Rect2()
var _has_bounds := false
var _target_was_moving := false

var shake_tween: Tween
var _pan_tween: Tween
var _zoom_tween: Tween
var _follow_zoom := Vector2.ONE

signal pan_finished

func _ready() -> void:
	Effects.camera = self
	make_current()
	position_smoothing_enabled = false
	refresh_bounds()
	get_viewport().size_changed.connect(_on_viewport_resized)
	if start_in_overview:
		show_overview(0.0)
	elif target:
		snap_to_target()
# --------- PUBLIC ------------------		
func follow(new_target: Node2D, pan_time := 0.0) -> void:
	target = new_target
	_target_was_moving = false
	if mode == Mode.OVERVIEW:
		return
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
	if target and mode != Mode.OVERVIEW:
		global_position = _clamp_to_bounds(_follow_point())
		
func recenter() -> void:
	if mode == Mode.OVERVIEW:
		exit_overview()
	else:
		mode = Mode.FOLLOW
		
func show_overview(time := overview_time) -> void:
	if not _has_bounds:
		push_warning("GameCamera: no bounds. missing TileMapLayer")
		return
	_kill_pan()
	is_dragging = false
	if mode != Mode.OVERVIEW:
		_follow_zoom = zoom
	mode = Mode.OVERVIEW
	_tween_view(_bounds.grow(bounds_margin).get_center(), _overview_zoom(), time)
	
func exit_overview(time := overview_time) -> void:
	if mode != Mode.OVERVIEW:
		return
	mode = Mode.FOLLOW
	_kill_zoom()
	if time <= 0.0:
		zoom = _follow_zoom
		return
	_zoom_tween = create_tween()
	_zoom_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_zoom_tween.tween_property(self, "zoom", _follow_zoom, time)
	
func toggle_overview() -> void:
	if mode == Mode.OVERVIEW:
		exit_overview()
		print("EXIT OVERVIEW")
	else:
		show_overview()
		print("SHOW_OVERVIEW")
		
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
	if event.is_action_pressed("camera_overview"):
		toggle_overview()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("camera_pan"):
		if mode == Mode.OVERVIEW:
			return
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
	if mode == Mode.OVERVIEW:
		return
	
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
	
func _kill_zoom() -> void:
	if _zoom_tween and _zoom_tween.is_valid():
		_zoom_tween.kill()
	_zoom_tween = null
	
func _overview_zoom() -> Vector2:
	var r := _bounds.grow(bounds_margin)
	var view := get_viewport_rect().size
	var z := minf(view.x / r.size.x, view.y / r.size.y)
	if pixel_perfect_overview and z >= 1.0:
		z = floorf(z)
	return Vector2(z, z)
	
func _tween_view(pos: Vector2, new_zoom: Vector2, time: float) -> void:
	_kill_zoom()
	if time <= 0.0:
		global_position = pos
		zoom = new_zoom
		return
	_zoom_tween = create_tween().set_parallel(true)
	_zoom_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_zoom_tween.tween_property(self, "global_position", pos, time)
	_zoom_tween.tween_property(self, "zoom", new_zoom, time)

func _on_viewport_resized() -> void:
	if mode == Mode.OVERVIEW:
		show_overview(0.0)

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
