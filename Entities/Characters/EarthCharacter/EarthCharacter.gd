extends CharacterBase
class_name EarthCharacter

func get_available_actions() -> Dictionary[String, ActionArray]:
	return {
		"default": ActionArray.create(
			[
				BaseMoveAction.create(
					self,
					get_move_distance_per_frame(),
					navigation_agent
				)
			]
		)
	}

func is_action_possible(_action: Action) -> bool:
	return true

func turn_resolution_advance(resolving_team: Enums.Team, _frame_count: int) -> void:
	if resolving_team == my_team:
		pass
