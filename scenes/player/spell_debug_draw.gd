extends Node2D
class_name SpellDebugDraw

@export var enabled := true
@onready var player := get_parent() as PlayerCharacter

func _ready() -> void:
	top_level = true 
	z_index = 100
	visible = enabled and OS.is_debug_build()

func _process(_delta: float) -> void:
	if not visible:
		return
	global_position = player.global_position
	queue_redraw()

func _draw() -> void:
	if not player.is_selected or player.spell == null:
		return
	player.spell.draw_debug(self, player)
