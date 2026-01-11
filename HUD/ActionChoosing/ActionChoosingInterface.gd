extends VBoxContainer
class_name ActionChoosingInterface


signal action_chosen(connected_signal: Signal, action: PlayerAction)



@onready var modifiers_container: HBoxContainer = $ModifiersContainer

@onready var choices_container: VBoxContainer = $ModifiersContainer/ChoicesContainer
@onready var choices: OptionButton = $ModifiersContainer/ChoicesContainer/Choices
@onready var choices_label: Label = $ModifiersContainer/ChoicesContainer/ChoicesLabel
@onready var switches: VBoxContainer = $ModifiersContainer/Switches



@onready var actions_container: HBoxContainer = $ActionsContainer

var available_actions: Dictionary[String, PlayerActionArray]

var focused_action: PlayerAction

func _ready() -> void:
	choices.item_selected.connect(choice_selected)

func set_character(character: CharacterBase) -> void:
	set_available_actions(character.get_available_actions())
	populate_action_buttons()
	action_chosen.connect(character.action_selected)

func set_available_actions(actions: Dictionary[String, PlayerActionArray]) -> void:
	modifiers_container.hide()
	choices_container.hide()
	available_actions = {}
	for title: String in actions.keys():
		available_actions.set(title, PlayerActionArray.new())
		for action: PlayerAction in actions.get(title).array:
			available_actions.get(title).array.append(action.clone())

func populate_action_buttons() -> void:
	var new_action_buttons: Array[ActionButton] = []
	for array: PlayerActionArray in available_actions.values():
		for action: PlayerAction in array.array:
			new_action_buttons.append(ActionButton.create(action))
	
	var actions_container_children: Array[Node] = actions_container.get_children()
	for node: Node in actions_container_children:
		if node is ActionButton:
			var action_button_connections: Array = node.action_pressed.get_connections()
			for action_button_connection: Variant in action_button_connections:
				if action_button_connection is Dictionary:
					node.action_pressed.disconnect(action_button_connection.get("callable"))
		node.queue_free()
	
	for action_button: ActionButton in new_action_buttons:
		print(action_button.my_action.action_name)
		action_button.action_pressed.connect(_action_pressed)
		actions_container.add_child.call_deferred(action_button)

func choice_selected(index: int) -> void:
	if (not focused_action.choices.is_empty()) and index != -1:
		focused_action.chosen_choice = focused_action.choices[index]
		print(focused_action.chosen_choice)
	else:
		focused_action.chosen_choice = ""

func clear_switches() -> void:
	for node: Node in switches.get_children():
		node.queue_free()

func add_switches(switches_array: Array[ActionModifierSwitch]) -> void:
	for switch: ActionModifierSwitch in switches_array:
		switches.add_child.call_deferred(switch)

func switch_updated(switch_title: String, value: bool) -> void:
	if focused_action.switches.has(switch_title):
		focused_action.switches.set(switch_title, value)
		print(focused_action.switches)

## is called by buttons to notify the interface that one has been clicked. should open up options and switches and stuff.
func _action_pressed(pressed_action: PlayerAction) -> void:
	focused_action = pressed_action
	update_available_modifiers(pressed_action)

func update_available_modifiers(action: PlayerAction) -> void:
	if not action.choices.is_empty():
		choices.clear()
		
		choices_label.text = action.choices_title
		
		for i: int in action.choices.size():
			choices.add_item(action.choices[i], i)
			if action.choices[i] == action.chosen_choice:
				choices.select(i)
		
		choice_selected(choices.get_selected_id())
		
		choices_container.show()
	else:
		choices_container.hide()
		choice_selected(-1)
	
	if not action.switches.is_empty():
		clear_switches()
		
		var switches_array: Array[ActionModifierSwitch] = []
		for switch_title: String in action.switches.keys():
			var current_switch: ActionModifierSwitch = ActionModifierSwitch.create(switch_title, action.switches.get(switch_title))
			switches_array.append(current_switch)
			current_switch.changed.connect(switch_updated)
		
		add_switches(switches_array)
		
		switches.show()
	else:
		switches.hide()
