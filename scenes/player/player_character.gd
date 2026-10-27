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

var min_shot: float
var full_power_shot: float
var gravity: float
var bounciness: float
var friction: float
var meter_speed: float
var linear_damp: float
var stop_speed: float

var shot_power: float = 0.0
var _meter_time: float = 0.0

var can_act := true
var spell: Spell

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
	spell = data.spell
	min_shot = data.min_shot
	full_power_shot = data.full_power_shot
	gravity = data.gravity
	bounciness = data.bounciness
	friction = data.friction
	meter_speed = data.meter_speed
	linear_damp = data.linear_damp
	stop_speed = data.stop_speed
# -------------- STATE --------------
func _on_state_changed() -> void:
	fsm_debug_label.text = fsm.current_state.get_script().get_global_name()
	_refresh_preview()
	
func _grounded() -> void:
	var grounded_state := fsm.change_state(PlayerGroundedState) as PlayerGroundedState
	grounded_state.shoot_pressed.connect(_charging, CONNECT_ONE_SHOT)
	
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
	var unselected_state := fsm.change_state(PlayerUnselectedState) as PlayerUnselectedState
	

# --------------------------------------
func aim() -> void:
	var mouse_pos := get_global_mouse_position()
	pivot.look_at(mouse_pos)

func get_launch_direction() -> Vector2:
	return (global_position - get_global_mouse_position()).normalized()
	
func get_launch_speed() -> float:
	return lerpf(min_shot, full_power_shot, shot_power)
# --------- FX --------------
func trigger_explosion() -> void:
	var direction := get_launch_direction()
	velocity = direction * get_launch_speed()
	
	var fx := ExplosionEffect.instantiate()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)
	
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
#func update_spell(spell: Spell) -> void:
	#spell = spell if spell else null
	#if spell:
		#can_cast = true
		#print("Player Spell: " + spell.name)
	
func cast_spell() -> void:
	if can_cast and spell:
		spell.cast(self)
		can_cast = false
	else:
		print("That spell is on cooldown!")
		#TODO Play Sound
# --------- PREVIEW ----------
func _refresh_preview() -> void:
	if not trajectory_preview:
		return
	var aiming := fsm.current_state is PlayerGroundedState or fsm.current_state is PlayerChargingState
	trajectory_preview.visible = is_selected and can_act and aiming

# --------- TURN -------------
func select() -> void:
	is_selected = true
	_grounded()
	
func deselect() -> void:
	is_selected = false
	_unselected()

func turn_start() -> void:
	can_act = true
	await get_tree().create_timer(1.0).timeout # simulate animation delay
	if spell:
		can_cast = true
		
func _on_shot_finished() -> void:
	_grounded()
	end_turn.call_deferred()

func end_turn() -> void:
	can_act = false
	turn_finished.emit()
