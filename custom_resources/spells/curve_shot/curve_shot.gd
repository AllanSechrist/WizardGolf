extends Spell
class_name CurveShot

@export var curve_strength := 5.0
@export var curve_step := 1.0
@export var max_curve := 10.0

@export_range(0.0, 1.0) var curve_kept_on_bounce := 1.0

func is_castable(character: PlayerCharacter) -> bool:
	return character.fsm.current_state is PlayerAimingState

func cast(character: PlayerCharacter) -> void:
	super(character)
	character.shot_curve = curve_strength
	character.curve_kept_on_bounce = curve_kept_on_bounce

func adjust(character: PlayerCharacter, steps: int) -> void:
	character.shot_curve = clampf(character.shot_curve + steps * curve_step, -max_curve, max_curve)
	print(character.shot_curve)
