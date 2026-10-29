extends Resource
class_name EnemyData

@export var sprite: Texture2D
@export var spell: Spell

@export_group("Physics")
@export var friction: float = 120.0
@export var wall_bounce: float = 0.5
@export var ball_restitution: float = 0.9
@export var settle_speed: float = 5.0

@export_group("Player Hits")
@export var hit_transfer: float = 0.8
@export var min_hit_speed: float = 40.0
