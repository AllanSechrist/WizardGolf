extends Node

var camera: Camera2D

func shake(strength: float = 4.0, duration: float = 0.2) -> void:
	if camera:
		camera.shake(strength, duration)
