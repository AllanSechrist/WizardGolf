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
	enemy_manager.final_enemy.connect(_on_final_enemy)
	#enemy_manager.spell_acquired.connect(_on_new_spell)
	
	# Party
	party_manager.party_turn_finished.connect(_on_turn_finished)
	
	# Camera
	party_manager.selection_changed.connect(_on_selection_changed)
	if party_manager.selected:
		_attach_camera(party_manager.selected)
		_update_hud_for(party_manager.selected)
	hud.visible = true
	
# -------------- CAMERA ----------------
func _on_selection_changed(character: PlayerCharacter) -> void:
	_update_hud_for(character)
	_detach_camera()
	var target: RemoteTransform2D = character.get_node("CameraTransform")
	await _pan_camera_to(target.global_position, switch_pan_time)
	if character == party_manager.selected:
		_attach_camera(character)
		
func _attach_camera(character: PlayerCharacter) -> void:
	_follow = character.get_node("CameraTransform")
	_follow.remote_path = _follow.get_path_to(camera_2d)
	
func _detach_camera() -> void:
	if _follow:
		_follow.remote_path = NodePath()
	_follow = null

func _pan_camera_to(pos: Vector2, duration: float = pan_time) -> void:
	if _pan_tween and _pan_tween.is_valid():
		_pan_tween.kill()
	_pan_tween = create_tween()
	_pan_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_pan_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	_pan_tween.tween_property(camera_2d, "global_position", pos, duration)
	await _pan_tween.finished
	
func play_goal_reveal(enemy: Enemy) -> void:
	get_tree().paused = true
	_detach_camera()
	
	await _pan_camera_to(enemy.global_position, pan_time)
	enemy.process_mode = Node.PROCESS_MODE_ALWAYS
	await enemy.play_transformation()
	enemy.process_mode = Node.PROCESS_MODE_INHERIT
	var hole := enemy_manager.turn_into_hole(enemy)
	hole.putt_made.connect(_on_putt_made)
	
	var current := party_manager.selected
	await _pan_camera_to(current.get_node("CameraTransform").global_position, pan_time)
	_attach_camera(current)
	get_tree().paused = false
# -------------------------------------------
func _update_hud_for(character: PlayerCharacter) -> void:
	hud.update_spell(character.spell)
	_on_cast_icon_change(character.can_cast)
	
#func _on_new_spell(spell) -> void:
	#hud.update_spell(spell)
	#player.update_spell(spell)
	
func _on_cast_icon_change(can_cast: bool) -> void:
	if can_cast:
		hud.fade_in_icon()
	else:
		hud.fade_out_icon()

func _on_score_change(points: int) -> void:
	score += points
	hud.update_score(score)
	
func _on_turn_finished() -> void:
	turn += 1
	hud.update_turn(turn)
	
func _on_final_enemy(enemy: Enemy) -> void:
	play_goal_reveal(enemy)
	
func _on_putt_made() -> void:
	print("Putt Made")
	
	
