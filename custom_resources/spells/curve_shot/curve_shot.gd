extends Spell
class_name CurveShot

@export var curve_strength := 3.0

@export_range(0.0, 1.0) var curve_kept_on_bounce := 0.0

func is_castable(character: PlayerCharacter) -> bool:
	return character.fsm.current_state is PlayerAimingState

func cast(character: PlayerCharacter) -> void:
	super(character)
	character.shot_curve = curve_strength
	character.curve_kept_on_bounce = curve_kept_on_bounce
