extends Resource
class_name CharacterData

@export var icon: Texture2D
@export var weapon: Texture2D
@export var spell: Spell

@export_category("Stats")
@export var min_shot := 50.0
@export var full_power_shot := 500.0
@export var gravity := 1200.0
@export_range(0.0, 1.0, 0.01) var bounciness := 0.6
@export var friction := 1.8

@export_category("Meter")
@export var meter_speed: float = 1.1
