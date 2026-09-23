extends Node2D
class_name GameManager

@onready var player: Player = $Player
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var hud: HUD = $HUD
@onready var camera_2d: Camera2D = $Camera2D
@onready var follow: RemoteTransform2D = player.get_node("CameraTransform")

@export var pan_time := 1.0

var score = 0
var turn = 1
var goal = null

func _ready() -> void:
	# Enemy Manager
	enemy_manager.update_score.connect(_on_score_change)
	enemy_manager.final_enemy.connect(_on_final_enemy)
	
	# Player
	player.turn_finished.connect(_on_turn_finished)
	
	# Camera
	follow.remote_path = follow.get_path_to(camera_2d)
	
func play_goal_reveal(enemy: Node2D) -> void:
	get_tree().paused = true
	follow.update_position = false
	
	await _pan_camera_to(enemy.global_position)
	await enemy.play_transformation()
	var hole := enemy_manager.turn_into_hole(enemy)
	hole.putt_made.connect(_on_putt_made)
	await _pan_camera_to(player.global_position)
	
	follow.update_position = true
	get_tree().paused = false
	
func _pan_camera_to(pos: Vector2) -> void:
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera_2d, "global_position", pos, pan_time)
	await tween.finished

func _on_score_change(points: int) -> void:
	score += points
	hud.update_score(score)
	
func _on_turn_finished() -> void:
	turn += 1
	hud.update_turn(turn)
	
func _on_final_enemy(enemy: Enemy) -> void:
	play_goal_reveal(enemy)
	
func _on_putt_made() -> void:
	print("Putt Made")
	
