extends Spell
class_name ShadowStep

@export var time_scale = 0.3
@export var time_slow_duration = 2.0
@export var time_recovery = 0.1
@export_range(0.0, 1.0) var redirect_speed_keep := 0.9

func cast(character: PlayerCharacter) -> void:
	super(character)
	player.trajectory_preview.visible = true
	play_effect()

func play_effect() -> void:
	Effects.slow_time(time_scale, time_slow_duration, time_recovery)

func spell_action() -> void:
	var speed := player.velocity.length()
	var new_direction := player.get_launch_direction() * redirect_speed_keep
	player.velocity = new_direction * speed
	player.trajectory_preview.visible = false
	print("redirect: before=", speed, " after=", player.velocity.length())
