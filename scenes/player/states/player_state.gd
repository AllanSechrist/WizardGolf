extends State
class_name PlayerState

const GROUNDED = "Grounded"
const AIRBORNE = "Airborne"

var player: Player

func _ready() -> void:
	await owner.ready
	player = owner as Player
	assert(player != null, "The PlayerState state needs the Player node inorder to work, it should only be used in the player scene.")
