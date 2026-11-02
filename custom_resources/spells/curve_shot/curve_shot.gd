extends Spell
class_name CurveShot

@export var curve_strength := 2.0

@export_range(0.0, 1.0) var curve_kept_on_bounce := 0.0

func is_castable(player: PlayerCharacter) -> bool:
	return player.fsm.current_state is PlayerAimingState

func cast(player: PlayerCharacter) -> void:
	player.shot_curve = curve_strength
	player.curve_kept_on_bounce = curve_kept_on_bounce
