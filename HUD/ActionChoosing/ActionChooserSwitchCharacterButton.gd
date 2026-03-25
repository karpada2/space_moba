extends Button
class_name ActionChooserSwitchCharacterButton

signal switch_character(character: CharacterBase)

var my_character: CharacterBase

static func create(character: CharacterBase, given_button_group: ButtonGroup) -> ActionChooserSwitchCharacterButton:
	var temp: ActionChooserSwitchCharacterButton = ActionChooserSwitchCharacterButton.new()
	temp.my_character = character
	temp.text = character.get_display_name()
	temp.button_group = given_button_group
	temp.toggle_mode = true
	
	temp.toggled.connect(temp.attempt_switch_character)
	
	return temp

func attempt_switch_character(toggled_on: bool) -> void:
	if toggled_on:
		switch_character.emit(my_character)
