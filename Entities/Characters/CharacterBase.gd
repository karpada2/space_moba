@abstract
extends EntityBase
class_name CharacterBase


signal request_revive(character: CharacterBase)
signal respawn_countdown_changed(new_time_left: int)


@export var base_money_dropped_on_death: float = 500
@export var money_dropped_on_death_growth: float = 50
var total_money_dropped_on_death: float = 0.05


var respawn_countdown: int = 0

var detection_area: DetectionAreaComponent
var navigation_agent: NavigationAgent2D
@onready var target_visualizer: TargetVisualizer = $TargetVisualizer
@onready var target_chooser: TargetChooser = $TargetChooser
@onready var health_bar_and_name_display: OffsetHealthBarAndNameDisplay = $OnPlayerGUIHolder/OffsetHealthBarAndNameDisplay
@onready var money_handler_component: MoneyHandlerComponent = $MoneyHandlerComponent

# max movement speed in pixels/seconds
@export var move_speed_human: float = 50

@export var attack_range: float = 120

# how many pixels can be moved per turn
@onready var move_distance_per_turn: float = (move_speed_human*(float(TurnResolutionManager.FRAMES_PER_TURN)/Engine.physics_ticks_per_second))

var start_pos: Vector2

var next_chosen_action: Action
var ready_to_act: bool = false

var current_focused_action: Action

var last_frame_action_configured: bool = false

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
	
	health_bar_and_name_display.display_name = get_display_name()
	health_bar_and_name_display.associated_team = my_team
	
	TurnChoosingManager.choosing_start.connect(action_choosing_start)
	TurnChoosingManager.choosing_end.connect(action_choosing_end)
	
	TurnResolutionManager.resolution_started.connect(turn_resolution_start)
	TurnResolutionManager.resolution_advance.connect(turn_resolution_advance)
	TurnResolutionManager.resolution_ended.connect(turn_resolution_end)

func turn_resolution_start(_team: Enums.Team) -> void:
	pass

func turn_resolution_end(team: Enums.Team) -> void:
	if my_team != team and not is_alive():
			if respawn_countdown <= 0:
				request_revive.emit(self)
			respawn_countdown -= 1
			respawn_countdown_changed.emit(respawn_countdown)
	
	if team == my_team and is_alive():
		next_chosen_action.action_length_used += 1
		if next_chosen_action.action_length_used >= next_chosen_action.action_length_turns:
			next_chosen_action = null

func action_choosing_start(team: Enums.Team) -> void:
	pass
	
	if my_team == team and next_chosen_action == null and is_alive():
			target_chooser.enable()

func action_choosing_end(team: Enums.Team) -> void:
	if my_team == team:
		target_chooser.disable()
		
		target_visualizer.hide()

func calculate_navigation() -> void:
	_calculate_navigation(navigation_agent)

func action_choosing_advance() -> void:
	if current_focused_action != null and next_chosen_action == null and is_alive():
		if target_chooser.is_right_mouse_button_just_pressed():
			current_focused_action.reset_target()
		
		target_visualizer.is_valid = is_action_possible(current_focused_action)
		
		if current_focused_action.target_type == Action.TargetingType.POSITION:
			target_visualizer.choose_enabled(true, true, false)
			if not current_focused_action.is_configured():
				target_visualizer.set_target_position(target_chooser.get_mouse_target_position())
				if current_focused_action is BaseMoveAction:
					target_visualizer.line_visualization_enabled = true
					navigation_agent.target_position = target_chooser.get_mouse_target_position()
					calculate_navigation()
			else:
				target_visualizer.set_target_position( current_focused_action.target_position)
			
			
			if target_chooser.is_left_mouse_button_just_pressed() and not current_focused_action.is_configured():
				current_focused_action.set_target_position(target_chooser.get_mouse_target_position())
				navigation_agent.target_position = current_focused_action.target_position
				calculate_navigation()
				if not is_action_possible(current_focused_action):
					current_focused_action.reset_target()
		elif current_focused_action.target_type in [Action.TargetingType.ANY, Action.TargetingType.ENEMY, Action.TargetingType.ALLY]:
			if current_focused_action.is_configured():
				target_visualizer.choose_enabled(true, false, true)
				navigation_agent.target_position = current_focused_action.target_entity.global_position
				calculate_navigation()
			else:
				target_visualizer.choose_enabled(true, true, false)
				var target_entity: EntityBase = null
				if current_focused_action.target_type == Action.TargetingType.ANY:
					target_entity = target_chooser.get_any_target()
				elif current_focused_action.target_type == Action.TargetingType.ENEMY:
					target_entity = target_chooser.get_enemy_target()
				elif current_focused_action.target_type == Action.TargetingType.ALLY:
					target_entity = target_chooser.get_ally_target()
				
				if target_entity:
					target_visualizer.set_target_position(target_entity.global_position)
					navigation_agent.target_position = target_entity.global_position
				else:
					target_visualizer.set_target_position(target_chooser.get_mouse_target_position())
					navigation_agent.target_position = target_chooser.get_mouse_target_position()
				calculate_navigation()
			
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
					else:
						target_visualizer.set_target_entity(current_focused_action.target_entity)
						navigation_agent.target_position = current_focused_action.target_entity.global_position
						calculate_navigation()
		else:
			target_visualizer.choose_enabled()

func _on_move_path_changed() -> void:
	target_visualizer.set_line_points(navigation_agent.get_current_navigation_path())

func died() -> void:
	unreveal()
	health_bar_and_name_display.hide()
	target_visualizer.hide()
	target_chooser.disable()
	hurtbox_component.monitoring = false
	hurtbox_component.monitorable = false
	hurtbox_component.visible = false
	money_handler_component.lose_unsecured_money()
	respawn_countdown = 2
	respawn_countdown_changed.emit(respawn_countdown)

func revive(revive_location: Vector2, health_percent: float = 1.0) -> void:
	reveal()
	health_bar_and_name_display.show()
	target_visualizer.show()
	hurtbox_component.monitoring = true
	hurtbox_component.monitorable = true
	hurtbox_component.visible = true
	health_component.heal(health_component.max_health * health_percent)
	global_position = revive_location
	respawn_countdown = 0
	respawn_countdown_changed.emit(respawn_countdown)

func kill() -> void:
	health_component.deal_damage(health_component.max_health * 999)

func enable() -> void:
	show()
	detection_area.enable()

func disable() -> void:
	hide()
	detection_area.disable()

func reveal() -> void:
	show()
	health_bar_and_name_display.show()

func unreveal() -> void:
	hide()
	detection_area.disable()
	target_visualizer.hide()
	health_bar_and_name_display.hide()

func reveal_visible_enemies() -> void:
	self.show()
	detection_area.enable()
	for node: EntityBase in get_visible_enemies():
		node.reveal()

func get_visible_enemies() -> Array[EntityBase]:
	return detection_area.get_visible_enemies()

func turn_resolution_advance(resolving_team: Enums.Team, frame_count: int) -> void:
	if resolving_team == my_team and is_alive():
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

@abstract
func get_bounty_collection_radius() -> float

func get_total_money_dropped() -> float:
	return money_handler_component.get_money_dropped_on_death() + (base_money_dropped_on_death + (GameRoot.get_game_root().game_length * money_dropped_on_death_growth))

func create_wait_and_move_action(action: Action, wait_before_act: int) -> SequentialAction:
	if action.target_type == Action.TargetingType.NONE or action is EntityBase.BaseMoveAction:
		return SequentialAction.create(action.action_name, ActionArray.create([WaitAction.create(wait_before_act), action]))
	
	if action.target_type == Action.TargetingType.POSITION:
		navigation_agent.target_position = action.target_position
	else:
		if action.target_entity:
			navigation_agent.target_position = action.target_entity.global_position
		else:
			navigation_agent.target_position = self.global_position
	
	if navigation_agent.target_position.distance_to(global_position) < get_action_range(action):
		return SequentialAction.create(action.action_name, ActionArray.create([WaitAction.create(wait_before_act), action]))
	calculate_navigation()
	
	var path: PackedVector2Array = optimize_move_path(navigation_agent.get_current_navigation_path(), get_action_range(action), navigation_agent.target_position)
	
	var new_action: SequentialAction = SequentialAction.create(action.action_name, ActionArray.create([WaitAction.create(wait_before_act), BaseMoveAction.create(self, get_move_distance_per_frame(), null, path), action]))
	return new_action

func action_focused(action: Action) -> void:
	current_focused_action = action
	target_visualizer.show()

func get_move_distance_per_frame() -> float:
	return move_distance_per_turn/TurnResolutionManager.FRAMES_PER_TURN

func get_max_movement_distance_possible() -> float:
	return move_distance_per_turn

## Handles storing what action was selected and with what parameters
func action_selected(chosen_action: Action, wait_before_act: int) -> void:
	if next_chosen_action == null:
		ready_to_act = true
		next_chosen_action = create_wait_and_move_action(chosen_action, wait_before_act)
		current_focused_action = null
		target_chooser.enabled = false
	TurnChoosingManager.i_chose_action(self)

func is_alive() -> bool:
	return health_component.is_alive
