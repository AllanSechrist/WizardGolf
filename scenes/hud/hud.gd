extends CanvasLayer
class_name HUD

@onready var score: Label = %Score
@onready var turn: Label = %Turn
@onready var spell_panel: Control = $MarginContainer/SpellPanel
@onready var spell_icon: TextureRect = %SpellIcon
@onready var frame: NinePatchRect = %Frame


func _ready() -> void:
	score.text = "Score: %d" % 0
	turn.text = "Turn: %d" % 1
	spell_icon.texture = null
	
func update_score(new_score) -> void:
	score.text = "Score: %d" % new_score

func update_turn(new_turn) -> void:
	turn.text = "Turn: %d" % new_turn
	
func update_spell(spell) -> void:
	print("HUD Spell: " + spell.name)
	spell_icon.texture = spell.icon
	fade_in_icon()
	
func fade_out_icon() -> void:
	spell_panel.modulate = Color(1,1,1,0.5)
	
func fade_in_icon() -> void:
	spell_panel.modulate = Color(1,1,1,1)
