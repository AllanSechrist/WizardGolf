extends CanvasLayer
class_name HUD

@onready var score: Label = %Score

func _ready() -> void:
	score.text = "Score: %d" % 0
	
