extends Area2D
class_name Hole

signal putt_made

@export var max_capture_speed := 150.0
@export var capture_radius := 8.0
@export var drag := 400.0

var player: Player = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	# Animation stuff?
	
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		player = body
		
func _on_body_exited(body: Node2D) -> void:
	if body == player:
		player = null
		
func _physics_process(delta: float) -> void:
	if player == null:
		return
	player.velocity.x = move_toward(player.velocity.x, 0.0, drag * delta)
	if _can_make_putt():
		_made_putt()

func _can_make_putt() -> bool:
	var slow_enough := absf(player.velocity.x) <= max_capture_speed
	var close_enough := player.global_position.distance_to(global_position) <= capture_radius
	return slow_enough and close_enough

func _made_putt() -> void:
	player = null
	set_deferred("monitoring", false)
	putt_made.emit()
