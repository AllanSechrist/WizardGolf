extends Area2D
class_name Enemy

@export var data: EnemyData
#DEBUG
@export var hud: HUD # TODO: change to signal
#END DEBUG
@onready var sprite_2d: Sprite2D = $Sprite2D

func _ready() -> void:
	if data:
		sprite_2d.texture = data.sprite

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		hud.on_score_changed(1) #DEBUG TODO: Update to signal manager. 
		queue_free()
