extends CanvasLayer
class_name HUD

@export var fade_speed := 0.3

@onready var score: Label = %Score
@onready var turn: Label = %Turn
@onready var spell_panel: Control = $MarginContainer/SpellPanel
@onready var spell_icon: TextureRect = %SpellIcon
@onready var frame: NinePatchRect = %Frame

var fade_tween: Tween

func _ready() -> void:
	score.text = "Score: %d" % 0
	turn.text = "Turn: %d" % 1
	spell_icon.texture = null
	
func update_score(new_score: int) -> void:
	score.text = "Score: %d" % new_score

func update_turn(new_turn: int) -> void:
	turn.text = "Turn: %d" % new_turn
	
func update_spell(spell: Spell) -> void:
	print("HUD Spell: " + spell.name)
	spell_icon.texture = spell.icon if spell else null
	if spell:
		fade_in_icon()
	
func create_fade_tween(color: Color) -> void:
	if fade_tween:
		fade_tween.kill()
	fade_tween = create_tween()
	fade_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(spell_panel, "modulate", color, fade_speed)

func fade_out_icon() -> void:
	var fade_out = Color(1,1,1,0.5)
	create_fade_tween(fade_out)
	
func fade_in_icon() -> void:
	var fade_in = Color(1,1,1,1)
	create_fade_tween(fade_in)
