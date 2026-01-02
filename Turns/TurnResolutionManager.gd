extends Node

signal resolution_started(resolving_team: Enums.Team)

const FRAMES_PER_TURN: int = 240
@export var _current_team: Enums.Team = Enums.Team.GOOD

@onready var frame_counter: int = 0

func _physics_process(_delta: float) -> void:
	if frame_counter % FRAMES_PER_TURN == 0:
		if _current_team == Enums.Team.GOOD:
			_current_team = Enums.Team.EVIL
		else:
			_current_team = Enums.Team.GOOD
		resolution_started.emit(_current_team)
	frame_counter += 1

func get_resolving_team() -> Enums.Team:
	return _current_team
