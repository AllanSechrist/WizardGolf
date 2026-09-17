extends CanvasLayer
class_name HUD

@onready var score: Label = %Score

func _ready() -> void:
	score.text = "Score: %d" % 0
	
func update_score(new_score) -> void:
	# TODO change to singal call back
	score.text = "Score: %d" % new_score
