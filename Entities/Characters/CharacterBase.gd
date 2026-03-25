@abstract
extends EntityBase
class_name CharacterBase


var detection_area: DetectionAreaComponent
var navigation_agent: NavigationAgent2D
@onready var move_path_visualizer: Line2D = $MovePathVisualizer
@onready var position_select_indicator: Polygon2D = $PositionSelectIndicator

# max movement speed in pixels/second
@export var move_speed_human: float = 50

# how many pixels can be moved per turn
@onready var move_distance_per_turn: float = (move_speed_human/(Engine.physics_ticks_per_second))*TurnResolutionManager.FRAMES_PER_TURN

var start_pos: Vector2

var next_chosen_action: Action

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

func _physics_process(_delta: float) -> void:
	if current_focused_action != null:
		if current_focused_action.target_type == Action.TargetingType.POSITION:
			position_select_indicator.show()
			
			if Input.is_action_just_pressed("mouse_press") and not current_focused_action.is_configured():
				current_focused_action.set_target_position(get_global_mouse_position())
				if not is_action_possible(current_focused_action):
					current_focused_action.reset_target()
			
			
			if not current_focused_action.is_configured():
				position_select_indicator.global_position = get_global_mouse_position()
			else:
				position_select_indicator.global_position = current_focused_action.target_position
				if current_focused_action is BaseMoveAction:
					handle_move_action_position_select()
				else:
					move_path_visualizer.hide()
		else:
			position_select_indicator.hide()

func handle_move_action_position_select() -> void:
	move_path_visualizer.show()
	navigation_agent.target_position = current_focused_action.target_position
	
	calculate_navigation()

func _on_move_path_changed() -> void:
	navigation_path = navigation_agent.get_current_navigation_path()
	
	move_path_visualizer.clear_points()
	for i: int in range(navigation_path.size()):
		navigation_path[i] = to_local(navigation_path[i])
		move_path_visualizer.add_point(navigation_path[i])

func reveal() -> void:
	show()

func unreveal() -> void:
	self.hide()
	detection_area.disable()

func reveal_visible_enemies() -> void:
	self.show()
	detection_area.enable()
	for area: Area2D in detection_area.vision_cone_area.get_overlapping_areas():
		if area is HurtboxComponent:
			area.reveal()

func get_visible_enemies() -> Array[CharacterBase]:
	return detection_area.get_visible_enemies()

func turn_resolution_advance(resolving_team: Enums.Team, frame_count: int) -> void:
	if resolving_team == my_team:
		if not next_chosen_action.finished:
			next_chosen_action.run(frame_count)

## Returns actions sorted by type (base, abilities, items, etc.).[br]
## The actions in the ActionArrays should be duplicated and not the originals.
@abstract
func get_available_actions() -> Dictionary[String, ActionArray]

## Checks if the action with its current parameters is possible (e.g. for move, if the distance and path are valid).
@abstract
func is_action_possible(action: Action) -> bool

func action_focused(action: Action) -> void:
	current_focused_action = action

func get_move_distance_per_frame() -> float:
	return move_distance_per_turn/TurnResolutionManager.FRAMES_PER_TURN

func is_movement_possible(target_pos: Vector2) -> bool:
	navigation_agent.target_position = target_pos
	calculate_navigation()
	return navigation_agent.get_path_length()  <= get_max_movement_distance_possible()

func calculate_navigation() -> void:
	navigation_agent.is_target_reachable()

func get_max_movement_distance_possible() -> float:
	return move_distance_per_turn

## Handles storing what action was selected and with what parameters
func action_selected(chosen_action: Action) -> void:
	next_chosen_action = chosen_action
