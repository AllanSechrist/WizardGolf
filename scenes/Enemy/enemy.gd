extends CharacterBody2D
class_name Enemy

signal defeated(enemy: Enemy, cause: StringName)

@export var data: EnemyData
@export var death_effect: PackedScene

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var hitbox: Area2D = $Hitbox

var friction: float
var wall_bounce: float
var ball_restitution: float
var settle_speed: float
var hit_transfer: float
var min_hit_speed: float

var spell: Spell
var is_dead := false
var _sinking := false

func _ready() -> void:
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	if data:
		_apply_data()
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	
func _apply_data() -> void:
	sprite_2d.texture = data.sprite
	spell = data.spell
	friction = data.friction
	wall_bounce = data.wall_bounce
	ball_restitution = data.ball_restitution
	settle_speed = data.settle_speed
	hit_transfer = data.hit_transfer
	min_hit_speed = data.min_hit_speed
	
func _physics_process(delta: float) -> void:
	if is_dead or _sinking:
		return
		
	velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	if velocity.length() < settle_speed:
		velocity = Vector2.ZERO
		return
		
	var pre_velocity := velocity
	move_and_slide()
	_resolve_collisions(pre_velocity)
		
func _resolve_collisions(pre_velocity: Vector2) -> void:
	for i in get_slide_collision_count():
		var collision := get_slide_collision(i)
		var normal := collision.get_normal()
		var other := collision.get_collider()
		
		if other is Enemy:
			_collide_with_enemy(other, normal, pre_velocity)
		else:
			velocity = pre_velocity.bounce(normal) * wall_bounce

func _collide_with_enemy(other: Enemy, normal: Vector2, pre_velocity: Vector2) -> void:
	if other.is_dead or other._sinking:
		return
	var relative := pre_velocity.dot(normal) - other.velocity.dot(normal)
	if relative >= 0.0:
		return
	var impulse := (1.0 + ball_restitution) * 0.5 * relative
	velocity = pre_velocity - normal * impulse
	other.velocity += normal * impulse
	
func knock(new_velocity: Vector2) -> void:
	if is_dead or _sinking:
		return
	velocity = new_velocity

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body is not PlayerCharacter:
		return
	var player_speed := (body as PlayerCharacter).velocity.length()
	if player_speed < min_hit_speed:
		return
	var direction := (global_position - body.global_position).normalized()
	knock(direction * player_speed * hit_transfer)
	
func is_settled() -> bool:
	if is_dead:
		return true
	if _sinking:
		return false
	return velocity.length() < settle_speed
	
func fall_into_pocket(pocket: Node2D) -> void:
	if is_dead or _sinking:
		return
	_sinking = true
	velocity = Vector2.ZERO
	collision_shape_2d.set_deferred("disabled", true)
	hitbox.set_deferred("monitoring", false)
	
	var tween := create_tween().set_parallel()
	tween.tween_property(self, "global_position", pocket.global_position, 0.3)
	tween.tween_property(sprite_2d, "scale", Vector2.ZERO, 0.3)
	await tween.finished
	die(&"pocket")
	
func die(cause: StringName = &"unknown") -> void:
	if is_dead:
		return
	is_dead = true
	if death_effect:
		var fx := death_effect.instantiate()
		get_tree().current_scene.add_child(fx)
		fx.global_position = global_position
	defeated.emit(self, cause)
	print("Enemy Sunk!")
	queue_free()
