extends Resource
class_name Spell

@export var name: String
@export var icon: Texture2D
@export var effect_scene: PackedScene
@export var attach_to_caster: bool = false

signal finished

func cast(player: Player) -> void:
	pass

func play_effect(player: Player) -> void:
	if effect_scene:
		print("spell!")
		var parent: Node = player if attach_to_caster else null
		Effects.spawn(effect_scene, player.global_position, parent)
