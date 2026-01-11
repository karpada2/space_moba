extends Node

signal resolution_started(resolving_team: Enums.Team)
signal resolution_ended()
signal resolution_advance(resolving_team: Enums.Team, frame_count_of_turn: int)

const FRAMES_PER_TURN: int = 240
@export var _current_team: Enums.Team = Enums.Team.GOOD

var _is_resolving: bool = true
@onready var frame_counter: int = 0

func _physics_process(_delta: float) -> void:
	if _is_resolving:
		if frame_counter == 0:
			resolution_started.emit(_current_team)
			frame_counter += 1
		elif frame_counter % FRAMES_PER_TURN == 0:
			if _current_team == Enums.Team.GOOD:
				_current_team = Enums.Team.EVIL
				frame_counter = 0
				#resolution_end()
			else:
				_current_team = Enums.Team.GOOD
				frame_counter = 0
				#resolution_end()
		else:
			resolution_advance.emit(_current_team, frame_counter)
			frame_counter += 1

func get_resolving_team() -> Enums.Team:
	return _current_team

func resolution_end() -> void:
	frame_counter = 0
	_is_resolving = false
	resolution_ended.emit()
