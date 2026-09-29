extends Node

var camera: Camera2D

func shake(strength: float = 4.0, duration: float = 0.2) -> void:
	if camera:
		camera.shake(strength, duration)

func spawn(scene: PackedScene, pos: Vector2, parent: Node = null) -> Node2D:
	print("spawn!")
	var fx := scene.instantiate() as Node2D
	if parent:
		parent.add_child(fx)
		fx.position = Vector2.ZERO
	else:
		get_tree().current_scene.add_child(fx)
		fx.global_position = pos
	return fx
