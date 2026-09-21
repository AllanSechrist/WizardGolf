extends CanvasLayer
class_name HUD

@onready var score: Label = %Score
@onready var turn: Label = %Turn


func _ready() -> void:
	score.text = "Score: %d" % 0
	turn.text = "Turn: %d" % 1
	
func update_score(new_score) -> void:
	score.text = "Score: %d" % new_score

func update_turn(new_turn) -> void:
	turn.text = "Turn: %d" % new_turn
