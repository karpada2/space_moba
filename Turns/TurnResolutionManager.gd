extends Node

signal resolution_started(resolving_team: Enums.Team)
signal resolution_advance(resolving_team: Enums.Team, frame_count_of_turn: int)

const FRAMES_PER_TURN: int = 240
@export var _current_team: Enums.Team = Enums.Team.GOOD

@onready var frame_counter: int = 0

func _physics_process(_delta: float) -> void:
	if frame_counter == 0:
		resolution_started.emit(_current_team)
		frame_counter += 1
	elif frame_counter % FRAMES_PER_TURN == 0:
		if _current_team == Enums.Team.GOOD:
			_current_team = Enums.Team.EVIL
			frame_counter = 0
		else:
			_current_team = Enums.Team.GOOD
			frame_counter = 0
	else:
		resolution_advance.emit(_current_team, frame_counter)
		frame_counter += 1

func get_resolving_team() -> Enums.Team:
	return _current_team
