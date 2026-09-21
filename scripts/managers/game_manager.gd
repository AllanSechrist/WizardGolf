extends Node2D
class_name GameManager

@onready var player: Player = $Player
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var hud: HUD = $HUD

var score = 0
var turn = 1

func _ready() -> void:
	enemy_manager.update_score.connect(_on_score_change)
	player.turn_finished.connect(_on_turn_finished)
	
func _on_score_change(points: int) -> void:
	score += points
	hud.update_score(score)
	
func _on_turn_finished() -> void:
	turn += 1
	hud.update_turn(turn)
