extends Camera2D
class_name GameCamera

var shake_tween: Tween

func _ready() -> void:
	Effects.camera = self

func shake(strength: float = 4.0, duration: float = 0.2, shakes: int = 6) -> void:
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
		
	shake_tween = create_tween()
	var step := duration / shakes
	
	for i in shakes:
		var falloff := 1.0 - float(i) /shakes
		var target := Vector2(randf_range(-1, 1), randf_range(-1, 1)) * strength * falloff
		shake_tween.tween_property(self, "offset", target, step)
		
	shake_tween.tween_property(self, "offset", Vector2.ZERO, step)
