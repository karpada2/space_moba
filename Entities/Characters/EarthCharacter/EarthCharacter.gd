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
					BasicAttack.create(18, Enums.DamageType.PHYSICAL, self),
					character_stats
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

func get_bounty_collection_radius() -> float:
	return 400

func get_portrait() -> Texture2D:
	return preload("res://HUD/Minimaps/Icons/EarthIcon.png")
