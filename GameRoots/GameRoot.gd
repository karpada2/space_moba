@abstract
extends Node2D
class_name GameRoot

class CharacterArray extends Resource:
	var array: Array[CharacterBase]

static var _current_game_root: GameRoot
var current_turn_phase: TurnPhase

func _ready() -> void:
	self._current_game_root = self

static func get_game_root() -> GameRoot:
	return _current_game_root

@abstract func resolution_started(team: Enums.Team) -> void

## returns all characters that are visible to the requested team
@abstract
func get_all_visible_characters(team: Enums.Team) -> Array[CharacterBase]

func reveal_as_needed(team: Enums.Team) -> void:
	var all_characters: Array[CharacterBase] = get_all_characters()
	
	for character: CharacterBase in all_characters:
		character.unreveal()
	
	for character: CharacterBase in get_characters_in_team(team):
		character.reveal()
		character.reveal_visible_enemies()

@abstract
func get_all_characters() -> Array[CharacterBase]

@abstract
func get_characters_in_team(team: Enums.Team) -> Array[CharacterBase]
