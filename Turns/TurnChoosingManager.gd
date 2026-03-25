extends Node

signal choosing_start(choosing_team: Enums.Team)
signal choosing_end(choosing_team: Enums.Team)

var has_chosen: Dictionary[CharacterBase, bool]
var current_choosing_team_characters: Array[CharacterBase]
var current_choosing_team: Enums.Team

var _in_choosing_phase: bool = false

var action_chooser_character_switchers: Array[ActionChooserSwitchCharacterButton] = []
var action_chooser_character_switchers_group: ButtonGroup = create_action_chooser_character_switcher_button_group()
var action_choosing_interface: ActionChoosingInterface
var action_choosing_character_switchers_container: HBoxContainer


func _physics_process(_delta: float) -> void:
	if is_choosing_now():
		action_choosing_interface.last_character.action_choosing_advance()

func create_action_chooser_character_switcher_button_group() -> ButtonGroup:
	var temp: ButtonGroup = ButtonGroup.new()
	temp.allow_unpress = false
	return temp

func start_choosing(team: Enums.Team) -> void:
	_in_choosing_phase = true
	
	has_chosen.clear()
	current_choosing_team_characters = GameRoot.get_game_root().get_characters_in_team(team)
	current_choosing_team = team
	
	for character: CharacterBase in current_choosing_team_characters:
		has_chosen.set(character, false)
	
	
	for character: CharacterBase in current_choosing_team_characters:
		action_chooser_character_switchers.append(ActionChooserSwitchCharacterButton.create(character, action_chooser_character_switchers_group))
		action_chooser_character_switchers.back().switch_character.connect(action_choosing_interface.set_character)
		action_choosing_character_switchers_container.add_child(action_chooser_character_switchers.back())
	
	action_chooser_character_switchers[0].button_pressed = true
	
	choosing_start.emit(team)

func i_chose_action(character: CharacterBase) -> void:
	if has_chosen.has(character):
		has_chosen.set(character, true)
		if has_chosen.values().all(func(n: bool) -> bool: return n):
			_end_choosing()

func _end_choosing() -> void:
	_in_choosing_phase = false
	
	for action_chooser_character_switcher: ActionChooserSwitchCharacterButton in action_chooser_character_switchers:
		action_chooser_character_switcher.switch_character.disconnect(action_choosing_interface.set_character)
		action_chooser_character_switcher.queue_free()
	
	action_chooser_character_switchers.clear()
	
	choosing_end.emit(current_choosing_team)

func is_choosing_now() -> bool:
	return _in_choosing_phase
