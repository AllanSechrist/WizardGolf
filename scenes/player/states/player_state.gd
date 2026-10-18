extends State
class_name PlayerState

const GROUNDED = "Grounded"
const AIRBORNE = "Airborne"
const ROLLING = "Rolling"
const CHARGING = "Charging"
const CASTING = "Casting"

var player: PlayerCharacter

func _ready() -> void:
	await owner.ready
	player = owner as PlayerCharacter
	assert(player != null, "The PlayerState state needs the PlayerCharacter node inorder to work, it should only be used in the player scene.")
