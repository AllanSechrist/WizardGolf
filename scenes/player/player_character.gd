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


@export_category("Stats")
@export var data: CharacterData
@export var min_shot := 50.0
@export var full_power_shot := 500.0
@export var gravity := 1200.0
@export_range(0.0, 1.0, 0.01) var bounciness := 0.6
@export var friction := 1.8

@export_category("Meter")
@export var meter_speed: float = 1.1

var shot_power: float = 0.0
var _meter_time: float = 0.0

var can_act := true

var spell: Spell

signal turn_finished
signal cast_icon_change(can_cast: bool)

var can_cast := false:
	set(value):
		can_cast = value
		cast_icon_change.emit(value)

const ExplosionEffect := preload("res://scenes/FX/explosion/explosion.tscn")

func _ready() -> void:
	power_meter.visible = false
	character.texture = data.icon
	wand.texture = data.weapon
	spell = data.spell
	can_act = true
	_grounded()
	fsm.state_changed.connect(_on_state_changed)
# -------------- STATE --------------
func _on_state_changed() -> void:
	fsm_debug_label.text = fsm.current_state.get_script().get_global_name()
	
func _grounded() -> void:
	var grounded_state := fsm.change_state(PlayerGroundedState) as PlayerGroundedState
	grounded_state.shoot_pressed.connect(_charging, CONNECT_ONE_SHOT)
	
func _charging() -> void:
	var charging_state := fsm.change_state(PlayerChargingState) as PlayerChargingState
	charging_state.shoot_pressed.connect(_rolling, CONNECT_ONE_SHOT)
	
func _rolling() -> void:
	var rolling_state := fsm.change_state(PlayerRollingState) as PlayerRollingState
	rolling_state.cast_pressed.connect(_casting, CONNECT_ONE_SHOT)
	rolling_state.stopped.connect(_grounded, CONNECT_ONE_SHOT)
	
func _casting() -> void:
	var casting_state := fsm.change_state(PlayerCastingState) as PlayerCastingState
	casting_state.cast_pressed.connect(_rolling, CONNECT_ONE_SHOT)
	casting_state.stopped.connect(_grounded, CONNECT_ONE_SHOT)
# --------------------------------------

func _physics_process(_delta: float) -> void:
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

# --------- TURN -------------
func turn_start() -> void:
	print("Turn Start!")
	can_act = true
	await get_tree().create_timer(1.0).timeout # simulate animation delay
	if spell:
		can_cast = true

func end_turn() -> void:
	can_act = false
	turn_finished.emit()
