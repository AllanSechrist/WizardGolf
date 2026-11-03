extends CharacterBody2D
class_name PlayerCharacter

@onready var pivot: Marker2D = $Pivot
@onready var wand: Sprite2D = %Wand
@onready var character: Sprite2D = $Character
@onready var trajectory_preview: TrajectoryPreview = $TrajectoryPreview
@onready var power_meter: Control = $PowerMeter
@onready var power_bar: ProgressBar = $PowerMeter/PowerBar
@onready var fsm: FiniteStateMachine = $FiniteStateMachine
@onready var fsm_debug_label: Label = $FSMDebugLabel
@onready var selection_reticle: Sprite2D = $SelectionReticle

@export_category("Data")
@export var data: CharacterData

signal turn_finished
signal cast_icon_change(can_cast: bool)
signal shot_curve_changed(curve: float)
signal spin_changed(spin: Vector2i)

var min_shot: float
var full_power_shot: float
var gravity: float
var bounciness: float
var friction: float
var mass: float
var meter_speed: float
var linear_damp: float
var stop_speed: float

var shot_power: float = 0.0
var shot_direction := Vector2.ZERO
var _meter_time: float = 0.0

var can_act := true
var spell: Spell
var direction_snapshot: Vector2

var curve_kept_on_bounce := 0.0
var active_curve := 0.0
var curve_step := 1.0
var max_curve := 10.0

var max_spin: int
var spin := Vector2i.ZERO

var shot_curve := 0.0:
	set(value):
		shot_curve = value
		shot_curve_changed.emit(value)

var is_selected: bool = false:
	set(value):
		is_selected = value
		if selection_reticle:
			selection_reticle.visible = value
		_refresh_preview()

var can_cast := false:
	set(value):
		can_cast = value
		cast_icon_change.emit(value)

const ExplosionEffect := preload("res://scenes/FX/explosion/explosion.tscn")

func _ready() -> void:
	if data:
		_apply_data()
	_refresh_preview()
	power_meter.visible = false
	selection_reticle.visible = is_selected
	can_act = true
	_unselected()
	fsm.state_changed.connect(_on_state_changed)
	fsm_debug_label.text = fsm.current_state.get_script().get_global_name()
	
func _apply_data() -> void:
	character.texture = data.icon
	wand.texture = data.weapon
	spell = data.spell.duplicate() if data.spell else null
	curve_step = data.curve_step
	max_curve = data.max_curve
	min_shot = data.min_shot
	max_spin = data.max_spin
	full_power_shot = data.full_power_shot
	gravity = data.gravity
	bounciness = data.bounciness
	friction = data.friction
	mass = data.mass
	meter_speed = data.meter_speed
	linear_damp = data.linear_damp
	stop_speed = data.stop_speed
# -------------- STATE --------------
func _on_state_changed() -> void:
	fsm_debug_label.text = fsm.current_state.get_script().get_global_name()
	_refresh_preview()
	
func _grounded() -> void:
	var grounded_state := fsm.change_state(PlayerGroundedState) as PlayerGroundedState
	grounded_state.shoot_pressed.connect(_aiming, CONNECT_ONE_SHOT)
	
func _aiming() -> void:
	var aiming_state := fsm.change_state(PlayerAimingState) as PlayerAimingState
	aiming_state.shoot_pressed.connect(_charging, CONNECT_ONE_SHOT)
	
func _charging() -> void:
	var charging_state := fsm.change_state(PlayerChargingState) as PlayerChargingState
	charging_state.shoot_pressed.connect(_rolling, CONNECT_ONE_SHOT)
	
func _rolling() -> void:
	var rolling_state := fsm.change_state(PlayerRollingState) as PlayerRollingState
	rolling_state.cast_pressed.connect(_casting, CONNECT_ONE_SHOT)
	rolling_state.stopped.connect(_on_shot_finished, CONNECT_ONE_SHOT)
	
func _casting() -> void:
	var casting_state := fsm.change_state(PlayerCastingState) as PlayerCastingState
	casting_state.cast_pressed.connect(_rolling, CONNECT_ONE_SHOT)
	casting_state.stopped.connect(_on_shot_finished, CONNECT_ONE_SHOT)
	
func _unselected() -> void:
	var _unselected_state := fsm.change_state(PlayerUnselectedState) as PlayerUnselectedState
	

# --------------------------------------
func aim() -> void:
	var mouse_pos := get_global_mouse_position()
	pivot.look_at(mouse_pos)

func snapshot_direction() -> void:
	direction_snapshot = get_launch_direction()
	
func get_launch_direction() -> Vector2:
	return (global_position - get_global_mouse_position()).normalized()
	
func get_launch_speed() -> float:
	return lerpf(min_shot, full_power_shot, shot_power)
	
func apply_hit_response(delta_velocity: Vector2) -> void:
	velocity += delta_velocity
	
func step_velocity(vector: Vector2, curve: float, delta: float) -> Vector2:
	vector *= exp(-linear_damp * delta)
	vector = vector.move_toward(Vector2.ZERO, friction * delta)
	if curve != 0.0:
		vector = vector.rotated(curve * delta)
	return vector
# --------- FX --------------
func trigger_explosion() -> void:
	shot_direction = direction_snapshot
	velocity = direction_snapshot * get_launch_speed()
	active_curve = shot_curve * get_curve_sign(direction_snapshot)
	var fx := ExplosionEffect.instantiate()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)
	direction_snapshot = Vector2.ZERO
	
# --------- METER ---------
func update_power_meter(delta: float) -> void:
	_meter_time += delta
	shot_power = pingpong(_meter_time * meter_speed, 1.0)
	power_bar.value = shot_power
	
func start_power_meter() -> void:
	_meter_time = 0.0
	shot_power = 0.0
	power_bar.value = 0.0
	power_meter.visible = true

func hide_power_meter() -> void:
	power_meter.visible = false
	
# ----------- RETICLE ---------
func toggle_reticle_on() -> void:
	selection_reticle.visible = true
	
func toggle_reticle_off() -> void:
	selection_reticle.visible = false
	
# --------- SPELLS ----------
func cast_spell() -> void:
	if can_cast and spell:
		spell.cast(self)
		can_cast = false
	else:
		print("That spell is on cooldown!")
		#TODO Play Sound

# ------------ CURVE/SPIN -----------
const FOLLOW_STEP := 0.25        
const DRAW_STEP := 0.3           
const SIDE_STEP := 0.25  
const WALL_ANGLE_STEP := PI / 12.0  
const LIVELY_STEP := 0.1        
const DEAD_STEP := 0.2          

func clear_shot_curve() -> void:
	shot_curve = 0.0
	active_curve = 0.0
	
func consume_spin() -> Vector2i:
	var s := spin
	spin = Vector2i.ZERO
	spin_changed.emit(spin)
	return s

func clear_spin() -> void:
	spin = Vector2i.ZERO
	spin_changed.emit(spin)
	
func apply_spin_on_wall(pre_velocity: Vector2, normal: Vector2) -> Vector2:
	# used by rolling state
	var s := consume_spin()
	var out := pre_velocity.bounce(normal) * bounciness
	if s.x != 0:
		out = out.rotated(s.x * WALL_ANGLE_STEP)
		if out.dot(normal) < 0.0: # hug wall
			out = out.slide(normal)
	elif s.y > 0:
		out *= 1.0 + s.y * LIVELY_STEP
	elif s.y < 0:
		out *= maxf(0.0, 1.0 + s.y * DEAD_STEP)
	return out
	
func apply_spin_on_enemy_hit(normal: Vector2, impact_speed: float) -> void:
	var s := consume_spin()
	if s.y > 0:
		velocity = normal * impact_speed * (s.y * FOLLOW_STEP)
	elif s.y < 0:
		velocity = normal * impact_speed * (s.y * DRAW_STEP)
	elif s.x != 0:
		var side := normal.rotated(PI / 2.0)
		velocity += side * impact_speed * (s.x * SIDE_STEP)

# --------- PREVIEW ----------
func _refresh_preview() -> void:
	if not trajectory_preview:
		return
	var aiming := fsm.current_state is PlayerAimingState
	trajectory_preview.visible = is_selected and can_act and aiming
	
func get_curve_sign(dir: Vector2) -> float:
	return -1.0 if dir.x < 0.0 else 1.0
	
# --------- TURN -------------
func select() -> void:
	is_selected = true
	_grounded()
	
func deselect() -> void:
	is_selected = false
	_unselected()

func turn_start() -> void:
	can_act = true
	clear_spin()
	clear_shot_curve()
	await get_tree().create_timer(1.0).timeout # simulate animation delay
	if spell:
		can_cast = true
		
func _on_shot_finished() -> void:
	clear_shot_curve()
	clear_spin()
	_grounded()
	end_turn.call_deferred()

func end_turn() -> void:
	can_act = false
	turn_finished.emit()
