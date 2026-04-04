extends Action
class_name SequentialAction

var actions_to_be_performed: ActionArray

static func create(action_name_in: String, actions: ActionArray) -> SequentialAction:
	var new_action: SequentialAction = SequentialAction.new()
	
	new_action.action_name = action_name_in
	new_action.actions_to_be_performed = actions
	new_action.resource_name = "SequentialAction"
	
	new_action.action_length_turns = int(ceilf(float(new_action.get_action_length_frames())/TurnResolutionManager.FRAMES_PER_TURN))
	
	return new_action

func get_action_length_frames(include_modifiers: bool = true) -> int:
	var sum: int = 0
	for i: int in range(actions_to_be_performed.array.size()):
		sum += actions_to_be_performed.array[i].get_action_length_frames(include_modifiers)
	return sum

func _new_inner() -> SequentialAction:
	return SequentialAction.new()

func clone() -> SequentialAction:
	var new_action: SequentialAction = _clone_inner()
	
	new_action.actions_to_be_performed = ActionArray.create(self.actions_to_be_performed.array.duplicate_deep(DEEP_DUPLICATE_ALL))
	
	return new_action

func run(frames_passed: int) -> bool:
	var return_value: bool = true
	if not actions_to_be_performed.array.is_empty():
		return_value = actions_to_be_performed.array.front().run(frames_passed)
	
	if not return_value:
		actions_to_be_performed.array.pop_front()
		return_value = run(frames_passed)
	
	if actions_to_be_performed.array.is_empty():
		finished = true
		return false
	return true
