extends Button
class_name ActionButton


signal action_pressed(pressed_action: PlayerAction)

var my_action: PlayerAction

func _ready() -> void:
	pressed.connect(action_pressed.emit.bind(my_action))

static func create(new_action: PlayerAction) -> ActionButton:
	var new_action_button: ActionButton = ActionButton.new()
	new_action_button.my_action = new_action
	new_action_button.text = new_action_button.my_action.action_name
	
	return new_action_button
