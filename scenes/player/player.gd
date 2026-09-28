extends CharacterBody2D
class_name Player

@onready var pivot: Marker2D = $Pivot
@onready var trajectory_preview: TrajectoryPreview = $TrajectoryPreview
@onready var power_meter: Control = $PowerMeter
@onready var power_bar: ProgressBar = $PowerMeter/PowerBar

@export_category("Stats")
@export var min_shot := 50.0
@export var full_power_shot := 500.0
@export var gravity := 1200.0
@export_range(0.0, 1.0, 0.01) var bounciness := 0.6
@export var friction := 1.0

@export_category("Meter")
@export var meter_speed: float = 1.1

var shot_power: float = 0.0
var _meter_time: float = 0.0

var current_spell: Spell

signal turn_finished
signal cast_icon_change(can_cast: bool)

var can_cast := false:
	set(value):
		can_cast = value
		cast_icon_change.emit(value)

const ExplosionEffect := preload("res://scenes/FX/explosion/explosion.tscn")

func _ready() -> void:
	power_meter.visible = false
	
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
func update_spell(spell: Spell) -> void:
	current_spell = spell if spell else null
	if spell:
		can_cast = true
		print("Player Spell: " + spell.name)
	
func cast_spell() -> void:
	if can_cast and current_spell:
		current_spell.cast(self)
		can_cast = false
	else:
		print("That spell is on cooldown!")
		#TODO Play Sound

# --------- TURN -------------
func turn_start() -> void:
	print("Turn Start!")
	await get_tree().create_timer(1.0).timeout # simlate animation delay
	if current_spell:
		can_cast = true

func end_turn() -> void:
	turn_finished.emit()
