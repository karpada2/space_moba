@tool
extends EntityBase
class_name Minion



class SetShaderMixAmountAction extends Action:
	var mix_amount: float
	var material_to_change: Material
	
	func get_action_length_frames() -> int:
		return 0
	
	func clone() -> SetShaderMixAmountAction:
		var new_action: SetShaderMixAmountAction = self._clone_inner()
		
		new_action.mix_amount = self.mix_amount
		
		return new_action
	
	func _new_inner() -> SetShaderMixAmountAction:
		return SetShaderMixAmountAction.new()
	
	static func create(mix_amount_in: float, material_to_change_in: Material) -> SetShaderMixAmountAction:
		var new_action: SetShaderMixAmountAction = SetShaderMixAmountAction.new()
		
		new_action.mix_amount = mix_amount_in
		new_action.material_to_change = material_to_change_in
		
		return new_action
	
	func run(_frames_passed: int) -> bool:
		if material_to_change:
			material_to_change.set("shader_parameter/mix_amount", mix_amount)
		return false


static var preloaded_minion: PackedScene = preload("res://Entities/Minions/SimpleMinion.tscn")
static var preload_good_sprite: Texture2D = preload("res://Entities/Minions/GoodMinionSprite.png")
static var preload_evil_sprite: Texture2D = preload("res://Entities/Minions/EvilMinionSprite.png")


static func create(team: Enums.Team) -> Minion:
	var new_minion: Minion = preloaded_minion.instantiate()
	
	new_minion.texture = preload_good_sprite if team == Enums.Team.GOOD else preload_evil_sprite
	new_minion.my_team = team
	
	return new_minion

@onready var navigation_agent: NavigationAgent2D = $NavigationAgent2D
@onready var detection_area: DetectionAreaComponent = $DetectionAreaComponent
@onready var health_bar_and_name_display: HealthBarAndNameDisplay = $GUIHolder/HealthBarAndNameDisplay
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var texture: Texture2D:
	set(value):
		if sprite_2d:
			sprite_2d.texture = value
		texture = value
# max movement speed in pixels/seconds
@export var move_speed_human: float = 250

@export var attack_range: float = 100

@export var frames_before_attacks: int = 10
@export var frames_after_attacks: int = 20

@export var attack_damage: float = 20
@onready var attack: Attack = Attack.create(self.attack_damage, Enums.DamageType.PHYSICAL)

@export_category("Targeting Weights")
@export var tower_targeting_weight: float = 300
@export var tower_distance_factor: float = 0.2
@export var character_targeting_weight: float = 20
@export var character_distance_factor: float = 0.3
@export var minion_targeting_weight: float = 5
@export var minion_distance_factor: float = 0.1

# how many pixels can be moved per turn
@onready var move_distance_per_turn: float = (move_speed_human*(float(TurnResolutionManager.FRAMES_PER_TURN)/Engine.physics_ticks_per_second))


var next_chosen_action: Action = null
var ready_to_act: bool = false
var last_target: EntityBase = null


func _ready() -> void:
	super()
	
	detection_area.my_team = my_team
	sprite_2d.texture = texture
	
	TurnChoosingManager.choosing_start.connect(set_health_bar_display)
	
	TurnResolutionManager.resolution_started.connect(turn_resolution_start)
	TurnResolutionManager.resolution_started.connect(set_health_bar_display)
	TurnResolutionManager.resolution_advance.connect(turn_resolution_advance)

func set_health_bar_display(team: Enums.Team) -> void:
	health_bar_and_name_display.as_enemy = team != my_team

func calculate_target_score(target: EntityBase) -> float:
	var score: float = -INF
	if target and target != self and target.my_team != self.my_team:
		var distance_factor: float = 0
		if target is TowerBase:
			score = tower_targeting_weight
			distance_factor = tower_distance_factor
		elif target is CharacterBase:
			score = character_targeting_weight
			distance_factor = character_distance_factor
		elif target is Minion:
			score = minion_targeting_weight
			distance_factor = minion_distance_factor
		
		score -= target.global_position.distance_to(self.global_position) * distance_factor
	return score

func get_enemy_to_attack() -> EntityBase:
	var possible_targets: Array[EntityBase] = GameRoot.get_game_root().get_all_visible_entities(my_team)
	
	var preferred_target: EntityBase = possible_targets.get(0)
	var preferred_target_score: float = calculate_target_score(preferred_target)
	
	for target: EntityBase in possible_targets:
		if calculate_target_score(target) > preferred_target_score:
			preferred_target = target
			preferred_target_score = calculate_target_score(target)
	
	if preferred_target_score != -INF:
		return preferred_target
	return null

func turn_resolution_start(team: Enums.Team) -> void:
	if my_team == team:
		if not (last_target and last_target.is_alive()):
			last_target = get_enemy_to_attack()
		
		if last_target:
			var temp_attack_action: EntityBase.BaseAttackAction = EntityBase.BaseAttackAction.create(attack)
			temp_attack_action.set_target_entity(last_target)
			var move_action: EntityBase.BaseMoveAction = create_move_action(temp_attack_action)
			@warning_ignore("integer_division")
			var attack_cycles_possible: int = int((TurnResolutionManager.FRAMES_PER_TURN - move_action.get_action_length_frames())/(frames_before_attacks + frames_after_attacks))
			var action_array: Array[Action] = [move_action]
			for _i: int in attack_cycles_possible:
				action_array.append_array([SetShaderMixAmountAction.create(0.5, material), WaitAction.create(frames_before_attacks), temp_attack_action.clone(), SetShaderMixAmountAction.create(1, material), WaitAction.create(frames_after_attacks), SetShaderMixAmountAction.create(0, material)])
			next_chosen_action = SequentialAction.create("Attack", ActionArray.create(action_array))
		else:
			navigation_agent.target_position = get_enemy_base_position()
			calculate_navigation()
			next_chosen_action = EntityBase.BaseMoveAction.create(self, get_move_distance_per_frame(), navigation_agent)
		
		if last_target:
			print(get_display_name(), " attempting to attack ", last_target.get_display_name(), " | target score: ", calculate_target_score(last_target))
		else:
			print(get_display_name(), " nothing to attack :(")
		ready_to_act = true

func turn_resolution_advance(team: Enums.Team, frames_passed: int) -> void:
	if my_team == team:
		if ready_to_act:
			ready_to_act = next_chosen_action.run(frames_passed)

func get_enemy_base_position() -> Vector2:
	return GameRoot.get_game_root().get_enemy_base_position(my_team)

func get_visible_enemies() -> Array[EntityBase]:
	return detection_area.get_visible_enemies()

func reveal_visible_enemies() -> void:
	self.show()
	detection_area.enable()
	for node: Node2D in get_visible_enemies():
		if node is CharacterBase:
			node.reveal()

func calculate_navigation() -> void:
	_calculate_navigation(navigation_agent)

func get_move_distance_per_frame() -> float:
	return move_distance_per_turn/TurnResolutionManager.FRAMES_PER_TURN

func get_max_movement_distance_possible() -> float:
	return move_distance_per_turn

func is_movement_possible(target_pos: Vector2) -> bool:
	navigation_agent.target_position = target_pos
	calculate_navigation()
	return navigation_agent.get_path_length() <= get_max_movement_distance_possible()

func reveal() -> void:
	show()
	health_bar_and_name_display.show()

func unreveal() -> void:
	hide()
	detection_area.disable()
	health_bar_and_name_display.hide()

func enable() -> void:
	reveal()
	detection_area.enable()

func disable() -> void:
	unreveal()

func died() -> void:
	self.queue_free()

func create_move_action(action: Action) -> EntityBase.BaseMoveAction:
	if action.target_entity:
		navigation_agent.target_position = action.target_entity.global_position
	else:
		navigation_agent.target_position = self.global_position
	
	if navigation_agent.target_position.distance_to(global_position) < attack_range:
		return EntityBase.NullBaseMoveAction.actual_create()
	calculate_navigation()
	
	var path: PackedVector2Array = optimize_move_path(navigation_agent.get_current_navigation_path(), attack_range, navigation_agent.target_position)
	
	var new_action: EntityBase.BaseMoveAction = EntityBase.BaseMoveAction.create(self, get_move_distance_per_frame(), null, path)
	return new_action
