extends CharacterBody2D
class_name Player

@onready var pivot: Marker2D = $Pivot
@onready var trajectory_preview: TrajectoryPreview = $TrajectoryPreview
@onready var power_meter: Control = $PowerMeter

@export var launch_speed := 500.0
@export var gravity := 1200.0
@export_range(0.0, 1.0, 0.01) var bounciness := 0.6
@export var friction := 1.0

signal turn_finished

const ExplosionEffect := preload("res://scenes/FX/explosion/explosion.tscn")

func _ready() -> void:
	power_meter.visible = false
	
func _physics_process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	pivot.look_at(mouse_pos)
	
func get_launch_direction() -> Vector2:
	return (global_position - get_global_mouse_position()).normalized()
		
func trigger_explosion() -> void:
	var direction := get_launch_direction()
	velocity = direction * launch_speed
	
	var fx := ExplosionEffect.instantiate()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)

func turn_start() -> void:
	print("Turn Start!")

func end_turn() -> void:
	turn_finished.emit()
