extends Resource
class_name Spell

@export var name: String
@export var icon: Texture2D
@export var effect_scene: PackedScene
@export var attach_to_caster: bool = false

signal finished

var player: PlayerCharacter

func cast(character: PlayerCharacter) -> void:
	player = character

func spell_action() -> void:
	pass

func play_effect() -> void:
	if effect_scene:
		print("spell!")
		var parent: Node = player if attach_to_caster else null
		Effects.spawn(effect_scene, player.global_position, parent)
