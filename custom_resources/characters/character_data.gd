extends Resource
class_name CharacterData

@export var icon: Texture2D
@export var weapon: Texture2D
@export var spell: Spell

@export_category("Stats")
@export var min_shot := 35.0
@export var full_power_shot := 420.0
@export var gravity := 1200.0
@export_range(0.0, 1.0, 0.01) var bounciness := 0.9
@export_range(0.1, 10.0, 0.1) var mass: float = 2.5
@export var friction := 60.0
@export var linear_damp := 0.105
@export var stop_speed := 4.2

@export_category("Curve")
@export var curve_step := 1.0
@export var max_curve := 10.0
@export_range(0.0, 1.0) var curve_kept_on_bounce := 0.0

@export_category("Spin")
@export var max_spin := 5

@export_category("Meter")
@export var meter_speed: float = 1.1
