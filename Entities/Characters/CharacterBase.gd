@abstract
extends EntityBase
class_name CharacterBase


var detection_area: DetectionAreaComponent
var navigation_agent: NavigationAgent2D
@onready var move_path_visualizer: Line2D = $MovePathVisualizer
@onready var position_select_indicator: Polygon2D = $PositionSelectIndicator
@onready var target_chooser: TargetChooser = $TargetChooser

static var position_targeting_color: Color = Color(1.0, 0.0, 1.0, 0.2)
const invalid_target_color: Color = Color(1.0, 0.0, 0.0, 0.3)

# max movement speed in pixels/second
@export var move_speed_human: float = 50

@export var attack_range: float = 70

# how many pixels can be moved per turn
@onready var move_distance_per_turn: float = (move_speed_human*(float(TurnResolutionManager.FRAMES_PER_TURN)/Engine.physics_ticks_per_second))

var start_pos: Vector2

var next_chosen_action: Action
var ready_to_act: bool = false

var current_focused_action: Action

var last_frame_action_configured: bool = false

var navigation_path: PackedVector2Array = []

func _ready() -> void:
	super()
	
	for node: Node in self.get_children():
		if node is DetectionAreaComponent:
			detection_area = node
		if node is NavigationAgent2D:
			navigation_agent = node
	
	detection_area.my_team = self.my_team
	hurtbox_component.revealed.connect(reveal)
	start_pos = global_position
	navigation_agent.path_changed.connect(_on_move_path_changed)
	
	target_chooser.my_team = self.my_team
	
	TurnChoosingManager.choosing_start.connect(action_choosing_start)
	
	TurnResolutionManager.resolution_advance.connect(turn_resolution_advance)

func action_choosing_start(team: Enums.Team) -> void:
	if my_team == team:
		target_chooser.enabled = true
		position_select_indicator.global_position = self.global_position
		move_path_visualizer.global_position = self.global_position
		
		position_select_indicator.hide()
		move_path_visualizer.hide()

func action_choosing_advance() -> void:
	if current_focused_action != null:
		if target_chooser.is_right_mouse_button_just_pressed():
			current_focused_action.reset_target()
		
		if current_focused_action.target_type == Action.TargetingType.POSITION:
			position_select_indicator.show()
			if not current_focused_action.is_configured():
				position_select_indicator.global_position = target_chooser.get_mouse_target_position()
				if current_focused_action is BaseMoveAction:
					move_path_visualizer.show()
					navigation_agent.target_position = target_chooser.get_mouse_target_position()
					calculate_navigation()
			else:
				position_select_indicator.global_position = current_focused_action.target_position
			
			
			
			if target_chooser.is_left_mouse_button_just_pressed() and not current_focused_action.is_configured():
				current_focused_action.set_target_position(target_chooser.get_mouse_target_position())
				navigation_agent.target_position = current_focused_action.target_position
				calculate_navigation()
				if not is_action_possible(current_focused_action):
					current_focused_action.reset_target()
			
			
			if is_action_possible(current_focused_action):
				position_select_indicator.color = position_targeting_color
				move_path_visualizer.default_color = position_targeting_color
			else:
				position_select_indicator.color = invalid_target_color
				move_path_visualizer.default_color = invalid_target_color
		elif current_focused_action.target_type in [Action.TargetingType.ANY, Action.TargetingType.ENEMY, Action.TargetingType.ALLY]:
			if target_chooser.is_left_mouse_button_just_pressed() and not current_focused_action.is_configured():
				if current_focused_action.target_type == Action.TargetingType.ANY:
					current_focused_action.set_target_entity(target_chooser.get_any_target())
				elif current_focused_action.target_type == Action.TargetingType.ENEMY:
					current_focused_action.set_target_entity(target_chooser.get_enemy_target())
				elif current_focused_action.target_type == Action.TargetingType.ALLY:
					current_focused_action.set_target_entity(target_chooser.get_ally_target())
				
				if current_focused_action.is_configured():
					if not is_action_possible(current_focused_action):
						current_focused_action.reset_target()
				
				if current_focused_action.is_configured():
					current_focused_action.target_entity.material.set("shader_parameter/mix_amount", 0.5)
		else:
			position_select_indicator.hide()
			move_path_visualizer.hide()

func _on_move_path_changed() -> void:
	navigation_path = navigation_agent.get_current_navigation_path()
	
	move_path_visualizer.clear_points()
	for i: int in range(navigation_path.size()):
		navigation_path[i] = to_local(navigation_path[i])
		move_path_visualizer.add_point(navigation_path[i])

func enable() -> void:
	show()
	detection_area.enable()

func reveal() -> void:
	show()

func unreveal() -> void:
	self.hide()
	detection_area.disable()
	position_select_indicator.hide()
	move_path_visualizer.hide()

func reveal_visible_enemies() -> void:
	self.show()
	detection_area.enable()
	for node: Node2D in get_visible_enemies():
		if node is CharacterBase:
			node.reveal()

func get_visible_enemies() -> Array[CharacterBase]:
	return detection_area.get_visible_enemies()

func turn_resolution_advance(resolving_team: Enums.Team, frame_count: int) -> void:
	if resolving_team == my_team:
		if ready_to_act:
			ready_to_act = next_chosen_action.run(frame_count)

## Returns actions sorted by type (base, abilities, items, etc.).[br]
## The actions in the ActionArrays should be duplicated and not the originals.
@abstract
func get_available_actions() -> Dictionary[String, ActionArray]

## Checks if the action with its current parameters is possible (e.g. for move, if the distance and path are valid).
@abstract
func is_action_possible(action: Action, wait_before_act: int = 0) -> bool

@abstract
func get_action_range(action: Action) -> float

func create_wait_and_move_action(action: Action, wait_before_act: int) -> SequentialAction:
	if action.target_type == Action.TargetingType.NONE or action is EntityBase.BaseMoveAction:
		return SequentialAction.create(action.action_name, ActionArray.create([WaitAction.create(wait_before_act), action]))
	
	var navigation_agent_desired_distance: float = navigation_agent.target_desired_distance
	navigation_agent.target_desired_distance = get_action_range(action)
	if action.target_type == Action.TargetingType.POSITION:
		navigation_agent.target_position = action.target_position
	else:
		if action.target_entity:
			navigation_agent.target_position = action.target_entity.global_position
		else:
			navigation_agent.target_position = self.global_position
	calculate_navigation()
	
	var new_action: SequentialAction = SequentialAction.create(action.action_name, ActionArray.create([WaitAction.create(wait_before_act), BaseMoveAction.create(self, get_move_distance_per_frame(), null, navigation_agent.get_current_navigation_path(), get_action_range(action)), action]))
	navigation_agent.target_desired_distance = navigation_agent_desired_distance
	return new_action

func action_focused(action: Action) -> void:
	current_focused_action = action
	position_select_indicator.hide()
	move_path_visualizer.hide()

func get_move_distance_per_frame() -> float:
	return move_distance_per_turn/TurnResolutionManager.FRAMES_PER_TURN

func is_movement_possible(target_pos: Vector2) -> bool:
	navigation_agent.target_position = target_pos
	calculate_navigation()
	return navigation_agent.get_path_length() <= get_max_movement_distance_possible()

func calculate_navigation(nav_agent_in: NavigationAgent2D = navigation_agent) -> void:
	nav_agent_in.is_target_reachable()

func get_max_movement_distance_possible() -> float:
	return move_distance_per_turn

## Handles storing what action was selected and with what parameters
func action_selected(chosen_action: Action, wait_before_act: int) -> void:
	next_chosen_action = create_wait_and_move_action(chosen_action, wait_before_act)
	TurnChoosingManager.i_chose_action(self)
	ready_to_act = true
	target_chooser.enabled = false
