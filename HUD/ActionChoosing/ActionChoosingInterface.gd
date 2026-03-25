extends VBoxContainer
class_name ActionChoosingInterface


signal action_chosen(action: Action, wait_frames_before_action: int)
signal action_focused(action: Action)

var last_character: CharacterBase


@onready var modifiers_container: HBoxContainer = $ModifiersContainer

@onready var choices_container: VBoxContainer = $ModifiersContainer/ChoicesContainer
@onready var choices: OptionButton = $ModifiersContainer/ChoicesContainer/Choices
@onready var choices_label: Label = $ModifiersContainer/ChoicesContainer/ChoicesLabel
@onready var switches: VBoxContainer = $ModifiersContainer/Switches
@onready var wait_before_acting_slider: HSlider = $ModifiersContainer/WaitBeforeContainer/HSlider
@onready var min_slider_value_showcase: Label = $ModifiersContainer/WaitBeforeContainer/MarginContainer/MinValueShowcase
@onready var max_slider_value_showcase: Label = $ModifiersContainer/WaitBeforeContainer/MarginContainer/MaxValueShowcase
@onready var current_slider_value_showcase: Label = $ModifiersContainer/WaitBeforeContainer/MarginContainer/CurrentValueShowcase

var lock_in_button: Button

@onready var actions_container: HBoxContainer = $ActionsContainer

var available_actions: Dictionary[String, ActionArray]

var focused_action: Action

func _ready() -> void:
	choices.item_selected.connect(choice_selected)
	set_lock_in_button($ActionsContainer/LockInButton)


func _physics_process(_delta: float) -> void:
	if focused_action:
		wait_before_acting_slider.max_value = TurnResolutionManager.FRAMES_PER_TURN - focused_action.get_action_length_frames()
		max_slider_value_showcase.text = str(int(wait_before_acting_slider.max_value))
		current_slider_value_showcase.text = str(int(wait_before_acting_slider.value))

func set_lock_in_button(new_button: Button) -> void:
	if lock_in_button != null and lock_in_button.pressed.is_connected(_on_lock_in_button_pressed):
		lock_in_button.pressed.disconnect(_on_lock_in_button_pressed)
	lock_in_button = new_button
	lock_in_button.pressed.connect(_on_lock_in_button_pressed)

func set_character(character: CharacterBase) -> void:
	if last_character != null:
		action_chosen.disconnect(character.action_selected)
		action_focused.disconnect(character.action_focused)
	set_available_actions(character.get_available_actions())
	populate_action_buttons()
	action_chosen.connect(character.action_selected)
	action_focused.connect(character.action_focused)
	last_character = character

func set_available_actions(actions: Dictionary[String, ActionArray]) -> void:
	available_actions = {}
	for title: String in actions.keys():
		available_actions.set(title, ActionArray.new())
		for action: Action in actions.get(title).array:
			available_actions.get(title).array.append(action.clone())

func populate_action_buttons() -> void:
	modifiers_container.hide()
	choices_container.hide()
	var new_action_buttons: Array[ActionButton] = []
	for array: ActionArray in available_actions.values():
		for action: Action in array.array:
			new_action_buttons.append(ActionButton.create(action))
	
	var actions_container_children: Array[Node] = actions_container.get_children()
	for node: Node in actions_container_children:
		if node is ActionButton:
			var action_button_connections: Array = node.action_pressed.get_connections()
			for action_button_connection: Variant in action_button_connections:
				if action_button_connection is Dictionary:
					node.action_pressed.disconnect(action_button_connection.get("callable"))
		
		if node != lock_in_button:
			node.queue_free()
	
	for action_button: ActionButton in new_action_buttons:
		action_button.action_pressed.connect(_action_pressed)
		actions_container.add_child.call_deferred(action_button)
	
	if lock_in_button != null:
		actions_container.move_child.call_deferred(lock_in_button, -1)

func choice_selected(index: int) -> void:
	if (not focused_action.choices.is_empty()) and index != -1:
		focused_action.chosen_choice = focused_action.choices[index]
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

## is called by buttons to notify the interface that one has been clicked. should open up options and switches and stuff.
func _action_pressed(pressed_action: Action) -> void:
	lock_in_button.disabled = false
	focused_action = pressed_action
	update_available_modifiers(pressed_action)
	
	action_focused.emit(focused_action)

func update_available_modifiers(action: Action) -> void:
	if not action.choices.is_empty():
		choices.clear()
		
		choices_label.text = action.choices_title
		
		for i: int in action.choices.size():
			choices.add_item(action.choices[i], i)
			if action.choices[i] == action.chosen_choice:
				choices.select(i)
		
		choice_selected(choices.get_selected_id())
		choices.disabled = false
		
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
	modifiers_container.show()

func _on_lock_in_button_pressed() -> void:
	if focused_action != null:
		action_chosen.emit(
			SequentialAction.create(focused_action.action_name, ActionArray.create([WaitAction.create(int(wait_before_acting_slider.value)), focused_action]))
			)
		lock_in_button.disabled = true
		for node: Node in actions_container.get_children():
			if node is BaseButton:
				node.disabled = true
		for node: Node in switches.get_children():
			if node is BaseButton:
				node.disabled = true
		choices.disabled = true
