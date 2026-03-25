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

func is_action_possible(action: Action) -> bool:
	return action.get_action_length_frames() <= TurnResolutionManager.FRAMES_PER_TURN
