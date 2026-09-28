extends Resource
class_name Spell

@export var name: String
@export var icon: Texture2D

signal finished

func cast(player: Player) -> void:
	pass

func play_effect(player: Player) -> void:
	pass
