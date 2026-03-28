@abstract
extends CharacterBody2D
class_name EntityBase


class BaseMoveAction extends Action:
	var navigation_total_time: int
	var my_entity: EntityBase
	var move_distance_per_frame: float
	var navigation_agent: NavigationAgent2D = null
	var path: PackedVector2Array
	var position_tolerance_squared: float
	var path_index: int = 1
	
	func get_action_length_frames() -> int:
		if navigation_agent != null:
			navigation_agent.is_target_reachable()
			navigation_total_time = int(navigation_agent.get_path_length()/self.move_distance_per_frame)+1
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
		my_entity.translate(translation_vector)
		finished = is_target_reached()
		return not is_target_reached()

## applies the attack only, combined with an animation action before and after to achieve cool effect. this way multi-hit-attacks and shit also work.
class BaseAttackAction extends Action:
	var attack: Attack
	
	func get_action_length_frames() -> int:
		return 0
	
	static func create(attack_in: Attack) -> BaseAttackAction:
		var new_action: BaseAttackAction = BaseAttackAction.new()
		new_action.action_name = "Attack"
		new_action.action_length_turns = 1
		new_action.target_type = TargetingType.ENEMY
		
		new_action.attack = attack_in
		
		return new_action
	
	func clone() -> BaseAttackAction:
		var new_action: BaseAttackAction = _clone_inner()
		new_action.attack = self.attack.clone()
		
		return new_action
	
	func _new_inner() -> BaseAttackAction:
		return BaseAttackAction.new()
	
	func run(_frames_passed: int) -> bool:
		target_entity.getting_hit_manager.attack(attack)
		return false

@export var my_team: Enums.Team = Enums.Team.NONE

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

@abstract
func reveal() -> void

@abstract
func unreveal() -> void

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

@abstract
func get_move_distance_per_frame() -> float

@abstract
func is_alive() -> bool
