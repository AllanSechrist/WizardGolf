extends Resource
class_name EnemyData

@export var sprite: Texture2D
@export var spell: Spell

@export_group("Physics")
@export_range(0.1, 10.0, 0.1) var mass: float = 1.0
@export var friction: float = 120.0
@export var wall_bounce: float = 0.5
@export var ball_restitution: float = 0.9
@export var settle_speed: float = 5.0

@export_group("Player Hits")
@export_range(0.0, 1.0, 0.05) var hit_restitution: float = 0.9
@export var min_hit_speed: float = 40.0
