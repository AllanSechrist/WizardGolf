extends RigidBody2D
class_name Player

@onready var camera_2d: Camera2D = $Camera2D
@onready var pivot: Marker2D = $Pivot

@export var explosion_strength := 100.0
@export var travel_speed := 200.0

@export_category("Gravity")
@export var gravity_rising := 800.0
@export var gravity_falling := 1400.0
@export var apex_threshold := 60.0
@export var apex_gravity := 200.0

const ExplosionEffect := preload("res://scenes/FX/explosion/explosion.tscn")
const MIN_SPEED_FOR_CLAMP := 50.0

func _ready() -> void:
	camera_2d.global_position = global_position
	gravity_scale = 0.0

func _physics_process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	pivot.look_at(mouse_pos)
	
	if Input.is_action_just_pressed("explode"):
		trigger_explosion()
		
func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var vel := state.linear_velocity
	var g: float
	
	if absf(vel.y) < apex_threshold:
		g = apex_gravity
	elif vel.y < 0.0:
		g = gravity_rising
	else:
		g = gravity_falling
	vel.y += g * state.step
	
	# constant speed
	if vel.length() > MIN_SPEED_FOR_CLAMP:
		vel = vel.normalized() * travel_speed
	
	state.linear_velocity = vel

func trigger_explosion() -> void:
	var direction = (global_position - get_global_mouse_position()).normalized()
	apply_central_impulse(direction * explosion_strength)
	
	var fx := ExplosionEffect.instantiate()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)
