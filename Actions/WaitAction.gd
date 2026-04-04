extends Action
class_name WaitAction

var action_length_frames: int
var frames_passed_this_action: int = 0

func get_action_length_frames(_include_modifiers: bool = true) -> int:
	return action_length_frames

func _new_inner() -> WaitAction:
	return WaitAction.new()

static func create(frames_to_wait: int) -> WaitAction:
	var new_action: WaitAction = WaitAction.new()
	new_action.action_length_frames = frames_to_wait
	new_action.resource_name = "WaitAction"
	
	return new_action

func clone() -> WaitAction:
	var new_action: WaitAction = _clone_inner()
	
	new_action.action_length_frames = self.action_length_frames
	
	return new_action

func run(_frames_passed: int) -> bool:
	frames_passed_this_action += 1
	finished = frames_passed_this_action >= action_length_frames
	return not finished
