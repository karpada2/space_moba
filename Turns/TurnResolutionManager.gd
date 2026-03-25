extends Node

signal resolution_started(resolving_team: Enums.Team)
signal resolution_ended()
signal resolution_advance(resolving_team: Enums.Team, frame_count_of_turn: int)

const FRAMES_PER_TURN: int = 160
var _current_team: Enums.Team = Enums.Team.NULL

var _is_resolving: bool = false
@onready var frame_counter: int = 0

func _physics_process(_delta: float) -> void:
	if _is_resolving:
		if frame_counter == 0:
			resolution_started.emit(_current_team)
			frame_counter += 1
		elif frame_counter == FRAMES_PER_TURN:
			resolution_end()
		else:
			resolution_advance.emit(_current_team, frame_counter)
			frame_counter += 1

func resolution_start(team: Enums.Team) -> void:
	if team != Enums.Team.NULL and team != Enums.Team.NONE:
		_is_resolving = true
	_current_team = team

func get_resolving_team() -> Enums.Team:
	return _current_team

func resolution_end() -> void:
	frame_counter = 0
	_is_resolving = false
	resolution_ended.emit()
