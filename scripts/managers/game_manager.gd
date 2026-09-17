extends Node2D
class_name GameManager

@onready var player: Player = $Player
@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var hud: HUD = $HUD

var score = 0

func _ready() -> void:
	enemy_manager.update_score.connect(_on_score_change)
	
func _on_score_change(points: int) -> void:
	score += points
	hud.update_score(score)
