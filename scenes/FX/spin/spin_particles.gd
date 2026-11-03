extends Node2D
class_name SpinParticles

@export var player: PlayerCharacter
@export var orbit_speed := 1.0

@onready var trail: GPUParticles2D = $Trail
@onready var orbit: GPUParticles2D = $Orbit


var _trail_mat: ParticleProcessMaterial
var _orbit_mat: ParticleProcessMaterial

func _ready() -> void:
	_trail_mat = trail.process_material as ParticleProcessMaterial
	_orbit_mat = orbit.process_material as ParticleProcessMaterial
	stop()
	
func _physics_process(_delta: float) -> void:
	if not player or not trail.emitting:
		return
	
	var dir := player.velocity.normalized() if player.velocity.length() > 1.0 else player.get_launch_direction()
	trail.rotation = dir.angle()

func show_spin(spin: Vector2i, max_spin: int) -> void:
	if spin == Vector2i.ZERO or max_spin <= 0:
		stop()
		return
	var strength := float(absi(spin.x) + absi(spin.y)) / max_spin
	
	if spin.y != 0:
		orbit.emitting = false
		_trail_mat.direction = Vector3(-signf(spin.y), 0.0, 0.0)
		trail.amount_ratio = strength
		trail.emitting = true
	else:
		trail.emitting = false
		var speed := signf(-spin.x) * orbit_speed
		_orbit_mat.orbit_velocity_min = speed
		_orbit_mat.orbit_velocity_max = speed
		orbit.amount_ratio = strength
		orbit.emitting = true

func stop() -> void:
	trail.emitting = false
	orbit.emitting = false
