extends Node
class_name PartyManager

signal selection_changed(character: PlayerCharacter)
signal party_turn_finished

var party: Array[PlayerCharacter] = []
var selected: PlayerCharacter
var _acted: Array[PlayerCharacter] = []

func _ready() -> void:
	for child in get_children():
		if child is PlayerCharacter:
			party.append(child)
			child.turn_finished.connect(_on_character_turn_finished.bind(child))
	start_party_turn()
	print(party)
	
func start_party_turn() -> void:
	_acted.clear()
	for character in party:
		character.turn_start()
	select(party[0])
	
func can_switch() -> bool:
	# only switch while current character is idle
	return selected == null or selected.fsm.current_state is not PlayerChargingState
	
func select(character: PlayerCharacter) -> void:
	if not can_switch() or character in _acted:
		return
	if selected:
		selected.is_selected = false
	selected = character
	character.is_selected = true
	selection_changed.emit(character)
	
func select_next() -> void:
	var i := party.find(selected)
	for step in range(1, party.size() + 1):
		var character := party[(i + step) % party.size()]
		if character not in _acted:
			select(character)
			return
			
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("cycle_character"):
		select_next()
		get_viewport().set_input_as_handled()
	
func _on_character_turn_finished(character: PlayerCharacter) -> void:
	_acted.append(character)
	if _acted.size() == party.size():
		party_turn_finished.emit()
	elif character == selected:
		select_next()
	
