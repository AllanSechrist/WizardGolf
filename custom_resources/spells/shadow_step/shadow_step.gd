extends Spell
class_name ShadowStep

@export var time_scale = 0.3
@export var time_slow_duration = 1.0
@export var time_recovery = 0.1

func cast(player: Player) -> void:
	play_effect(player)

func play_effect(player: Player) -> void:
	Effects.slow_time(time_scale, time_slow_duration, time_recovery)

func spell_action(player: Player) -> void:
	var speed := player.velocity.length()
	var new_direction := player.get_launch_direction()
	player.velocity = new_direction * speed
