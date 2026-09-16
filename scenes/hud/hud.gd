extends CanvasLayer
class_name HUD

@onready var score: Label = %Score

func _ready() -> void:
	score.text = "Score: %d" % 0
	
func on_score_changed(new_score) -> void:
	# TODO change to singal call back
	score.text = "Score: %d" % new_score
