extends CPUParticles2D
class_name Explosion

func _ready() -> void:
	finished.connect(queue_free)
	emitting = true
