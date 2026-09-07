extends CharacterBody2D
class_name Player

@onready var camera_2d: Camera2D = $Camera2D
@onready var pivot: Marker2D = $Pivot

@export var launch_speed := 500.0
@export var gravity := 1200.0

const ExplosionEffect := preload("res://scenes/FX/explosion/explosion.tscn")

func _ready() -> void:
	camera_2d.global_position = global_position
	
func _physics_process(delta: float) -> void:
	var mouse_pos := get_global_mouse_position()
	pivot.look_at(mouse_pos)
	
	if Input.is_action_just_pressed("explode"):
		trigger_explosion()
		
	if is_on_floor():
		velocity.x = 0
	else:
		velocity.y += gravity * delta
		
	move_and_slide()
	
func trigger_explosion() -> void:
	var direction := (global_position - get_global_mouse_position()).normalized()
	velocity = direction * launch_speed
	
	var fx := ExplosionEffect.instantiate()
	fx.global_position = global_position
	get_tree().current_scene.add_child(fx)
