extends CheckButton
class_name ActionModifierSwitch

signal changed(title: String, new_value: bool)

var title: String

static func create(title_in: String, starting_value: bool) -> ActionModifierSwitch:
	var newSwitch: ActionModifierSwitch = ActionModifierSwitch.new()
	newSwitch.title = title_in
	newSwitch.text = title_in
	newSwitch.button_pressed = starting_value
	
	newSwitch.pressed.connect(newSwitch.just_pressed)
	
	return newSwitch

func just_pressed() -> void:
	changed.emit(title, button_pressed)
