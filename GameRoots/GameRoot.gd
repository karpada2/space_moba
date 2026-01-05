@abstract
extends Node2D
class_name GameRoot

static var _current_game_root: GameRoot

func _ready() -> void:
	self._current_game_root = self

static func get_game_root() -> GameRoot:
	return _current_game_root


## returns all characters that are visible to the requested team
@abstract
func get_all_visible_characters(team: Enums.Team) -> Array[CharacterBase]

@abstract
func get_all_characters() -> Array[CharacterBase]

@abstract
func get_characters_in_team(team: Enums.Team) -> Array[CharacterBase]
