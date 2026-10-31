extends Node2D
class_name GameManager

@onready var enemy_manager: EnemyManager = $EnemyManager
@onready var party_manager: PartyManager = $PartyManager
@onready var hud: HUD = $HUD
@onready var camera_2d: Camera2D = $Camera2D

@export var pan_time := 1.0
@export var switch_pan_time := 0.4

var score := 0
var turn := 1

var _follow: RemoteTransform2D
var _pan_tween: Tween

func _ready() -> void:
	# Enemy Manager
	enemy_manager.update_score.connect(_on_score_change)
	enemy_manager.enemy_defeated.connect(_on_enemy_defeated)
	enemy_manager.all_enemies_defeated.connect(_on_all_enemies_defeated)
	#enemy_manager.spell_acquired.connect(_on_new_spell)
	
	# Party
	party_manager.shot_finished.connect(_on_shot_finished)
	party_manager.party_turn_finished.connect(_on_party_turn_finished)
	for character in party_manager.party:
		character.cast_icon_change.connect(_on_character_cast_icon_change.bind(character))
		
	# Camera
	party_manager.selection_changed.connect(_on_selection_changed)
	if party_manager.selected:
		camera_2d.follow(party_manager.selected)
		camera_2d.snap_to_target()
		_update_hud_for(party_manager.selected)
	hud.visible = true
	
# -------------- CAMERA ----------------
func _on_selection_changed(character: PlayerCharacter) -> void:
	_update_hud_for(character)
	camera_2d.follow(character, switch_pan_time) 
	
# -------------------------------------------
func _update_hud_for(character: PlayerCharacter) -> void:
	hud.update_spell(character.spell)
	_change_icon(character.can_cast)
	
func _on_character_cast_icon_change(can_cast: bool, character: PlayerCharacter) -> void:
	if character == party_manager.selected:
		_change_icon(can_cast)

func _change_icon(can_cast: bool) -> void:
	if can_cast:
		hud.fade_in_icon()
	else:
		hud.fade_out_icon()

func _on_score_change(points: int) -> void:
	score += points
	hud.update_score(score)
	
func _on_party_turn_finished() -> void:
	# TODO: Enemy phase
	turn += 1
	hud.update_turn(turn)
	party_manager.start_party_turn()
	
func _on_enemy_defeated(_enemy: Enemy, _cause: StringName, _remaining: int) -> void:
	pass
	
func _on_all_enemies_defeated() -> void:
	# TODO: level clear
	print("level cleared!")
	
func _on_shot_finished(_character: PlayerCharacter) -> void:
	await enemy_manager.wait_until_settled()
	party_manager.continue_turn()
	
	
