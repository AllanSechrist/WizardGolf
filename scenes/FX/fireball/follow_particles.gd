extends CPUParticles2D
class_name FollowParticles

@export var stop_speed: float = 5.0
@export var min_time: float = 0.1

var _target: CharacterBody2D
var _age := 0.0
var _stopping := false

func _ready() -> void:
	_target = get_parent() as CharacterBody2D
	one_shot = false
	emitting = true
	print("Follow!")
	
func _process(delta: float) -> void:
	if _stopping:
		return
	_age += delta
	if _target == null or (_age >= min_time and _target.velocity.length() < stop_speed):
		_stop()
		
func _stop() -> void:
	_stopping = true
	emitting = false
	await get_tree().create_timer(lifetime).timeout
	queue_free()
