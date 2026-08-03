@abstract
extends CharacterBody2D
class_name EntityBase


signal entity_died(entity: EntityBase)


class BaseMoveAction extends Action:
	var navigation_total_time: int
	var my_entity: EntityBase
	var move_distance_per_frame: float
	var navigation_agent: NavigationAgent2D = null
	var path: PackedVector2Array
	var position_tolerance_squared: float
	var path_index: int = 1
	
	func get_action_length_frames(_include_modifiers: bool = true) -> int:
		if navigation_agent != null:
			navigation_agent.is_target_reachable()
			navigation_total_time = int(ceilf(navigation_agent.get_path_length()/self.move_distance_per_frame))
		return navigation_total_time
	
	static func create(entity: EntityBase, move_distance_per_frame_in: float, navigation_agent_in: NavigationAgent2D = null, move_path: PackedVector2Array = [], position_tolerance: float = 0) -> BaseMoveAction:
		var new_action: BaseMoveAction = BaseMoveAction.new()
		var path_length: float = 0
		new_action.my_entity = entity
		new_action.action_name = "Move"
		new_action.move_distance_per_frame = move_distance_per_frame_in
		new_action.action_length_turns = 1
		new_action.target_type = TargetingType.POSITION
		
		if navigation_agent_in == null:
			for i: int in range(1, move_path.size()):
				path_length += (move_path[i] - move_path[i-1]).length()
			
			new_action.path = move_path
			new_action.position_tolerance_squared = position_tolerance**2
		else:
			new_action.navigation_agent = navigation_agent_in
			path_length = new_action.navigation_agent.get_path_length()
		new_action.navigation_total_time = int(path_length/move_distance_per_frame_in)+1
		return new_action
	
	func _new_inner() -> BaseMoveAction:
		return BaseMoveAction.new()
	
	func clone() -> BaseMoveAction:
		var new_action: BaseMoveAction = _clone_inner()
		
		new_action.navigation_total_time = self.navigation_total_time
		new_action.my_entity = self.my_entity
		new_action.move_distance_per_frame = self.move_distance_per_frame
		new_action.navigation_agent = self.navigation_agent
		new_action.path = self.path
		new_action.position_tolerance_squared = self.position_tolerance_squared
		
		return new_action
	
	func get_next_path_position() -> Vector2:
		if navigation_agent != null:
			return navigation_agent.get_next_path_position()
		
		if is_position_reached(path[path_index]):
			path_index += 1
		if path_index >= path.size():
			return my_entity.global_position
		return path[path_index]
	
	func is_position_reached(another_position: Vector2) -> bool:
		return (my_entity.global_position - another_position).length_squared() <= position_tolerance_squared
	
	func is_target_reached() -> bool:
		if navigation_agent != null:
			return navigation_agent.is_target_reached()
		else:
			return is_position_reached(path[-1])
	
	func run(_frames_passed: int) -> bool:
		var translation_vector: Vector2 = (get_next_path_position() - my_entity.global_position)
		translation_vector = translation_vector.limit_length(move_distance_per_frame)
		my_entity.global_rotation = translation_vector.angle()
		my_entity.translate(translation_vector)
		finished = is_target_reached()
		return not is_target_reached()

class NullBaseMoveAction extends BaseMoveAction:
	func get_action_length_frames(_include_modifiers: bool = true) -> int:
		return 0
	
	static func actual_create() -> BaseMoveAction:
		return NullBaseMoveAction.new()
	
	func run(_frames_passed: int) -> bool:
		return false

@export var my_team: Enums.Team = Enums.Team.NONE

var all_stat_affecters: Array[StatAffecter] = []
@export var inventory: Inventory

var getting_hit_manager: GettingHitManagerComponent
var health_component: HealthComponent
var hurtbox_component: HurtboxComponent

var _display_name: String
var _display_name_set: bool = false

# returns whether the name was set successfully
func set_display_name(new_name: String) -> bool:
	_display_name = new_name
	_display_name_set = true
	return true

func get_display_name() -> String:
	if not _display_name_set:
		set_display_name(self.name)
	return _display_name

func optimize_move_path(path_in: PackedVector2Array, wanted_distance: float, target_position: Vector2) -> PackedVector2Array:
	var path: PackedVector2Array = path_in.duplicate()
	if path.size() >= 2:
		var index_flag: bool = false
		var index: int
		if path.size() > 2:
			for i: int in range(path.size() - 1, 1, -1):
				if path[i].distance_to(target_position) < wanted_distance and path[i-1].distance_to(target_position) > wanted_distance:
					index = i
					index_flag = true
					break
		else:
			index = 1
			index_flag = true
		if index_flag:
			var diff_between_last: Vector2 = path[index] - path[index-1]
			var multiplier: float = 0.5
			for i: int in range(2, 8, 1):
				if (path[index-1] + (multiplier * diff_between_last)).distance_to(target_position) > wanted_distance:
					multiplier += pow(2, -i)
				else:
					multiplier -= pow(2, -i)
			var resulting_vector: Vector2 = path[index-1] + (multiplier * diff_between_last)
			if path.size() == 2:
				path = [path[0], resulting_vector]
			else:
				path = path.slice(0, index)
				path.append(resulting_vector)
	
	return path

@abstract
func reveal() -> void

@abstract
func unreveal() -> void

@abstract
func enable() -> void

@abstract
func disable() -> void

func _died() -> void:
	died()
	if not self.entity_died.is_connected(GameRoot.get_game_root().entity_died):
		self.entity_died.connect(GameRoot.get_game_root().entity_died)
	entity_died.emit(self)

@abstract
func died() -> void

@abstract
func get_total_money_dropped() -> float

@abstract
func get_portrait() -> Texture2D

func _ready() -> void:
	if my_team == Enums.Team.NONE:
		set_collision_layer_value(2, true)
		set_collision_layer_value(3, false)
		set_collision_layer_value(4, false)
	elif my_team == Enums.Team.GOOD:
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, true)
		set_collision_layer_value(4, false)
	else:
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, false)
		set_collision_layer_value(4, true)
	
	for node: Node in self.get_children():
		if node is HealthComponent:
			health_component = node
		elif node is GettingHitManagerComponent:
			getting_hit_manager = node
		elif node is HurtboxComponent:
			hurtbox_component = node
	
	hurtbox_component.owner_entity = self
	hurtbox_component.my_team = self.my_team
	getting_hit_manager.health_component = self.health_component
	getting_hit_manager.hurtbox_component = self.hurtbox_component
	getting_hit_manager.my_owner = self
	health_component.died.connect(_died)
	
	if GameRoot.get_game_root():
		self.entity_died.connect(GameRoot.get_game_root().entity_died)

@abstract
func get_base_stat_value(stat_name: Enums.EntityStats) -> ModifiedNumber

func get_stat(stat_name: Enums.EntityStats, base_stat: bool = false) -> float:
	var base_stat_value: ModifiedNumber = get_base_stat_value(stat_name)
	if base_stat:
		return base_stat_value.get_total()
	
	for stat_affecter: StatAffecter in all_stat_affecters:
		base_stat_value = stat_affecter.affect_stat(stat_name, base_stat_value)
	
	return base_stat_value.get_total()

@abstract
func get_move_distance_per_frame() -> float

@abstract
func get_visible_enemies() -> Array[EntityBase]

func _calculate_navigation(nav_agent_in: NavigationAgent2D) -> void:
	nav_agent_in.is_target_reachable()

func is_alive() -> bool:
	return health_component.is_alive
