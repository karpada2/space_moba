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
				),
				BaseAttackAction.create(
					Attack.create(100, Enums.DamageType.PHYSICAL)
				)
			]
		)
	}

func is_action_possible(action: Action, wait_before_act: int = 0) -> bool:
	return create_wait_and_move_action(action, wait_before_act).get_action_length_frames() <= TurnResolutionManager.FRAMES_PER_TURN*action.action_length_turns

func get_action_range(action: Action) -> float:
	if action is EntityBase.BaseMoveAction:
		return 0
	return attack_range
