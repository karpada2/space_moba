extends Button
class_name ActionButton


signal action_pressed(pressed_action: Action)

var my_action: Action

func _ready() -> void:
	pressed.connect(action_pressed.emit.bind(my_action))

static func create(new_action: Action) -> ActionButton:
	var new_action_button: ActionButton = ActionButton.new()
	new_action_button.my_action = new_action
	new_action_button.text = new_action_button.my_action.action_name
	new_action_button.action_mode = BaseButton.ACTION_MODE_BUTTON_RELEASE
	
	return new_action_button
