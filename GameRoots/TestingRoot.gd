extends GameRoot
class_name TestingRoot

var characters_by_team: Dictionary[Enums.Team, CharacterArray] = {}
@onready var navigation_region_2d: NavigationRegion2D = $WorldLayer/NavigationRegion2D

var is_between_turns: bool = false

const CHARACTER_KILL_SECURED_MONEY: float = 0.75
var kill_distance_contribution_buckets: CutoffBuckets = CutoffBuckets.create(
	[300, 800],
	[5, 3, 0],
	true
)

@onready var action_choosing_interface: ActionChoosingInterface = $PlayerSpecificHUD/VBoxContainer/ActionChoosingInterface
@onready var action_choosing_character_switchers_container: HBoxContainer = $PlayerSpecificHUD/VBoxContainer/ActionChoosingCharacterSwitchers
@onready var minimap: Minimap = $Minimaps/Minimap
@onready var between_players_blocker: Panel = $Blockers/BetweenPlayersBlocker
@onready var between_players_label: Label = $Blockers/BetweenPlayersBlocker/Label
@onready var after_resolution_blocker: Panel = $Blockers/AfterResolutionBlocker
@onready var minions: CanvasLayer = $Minions
@onready var current_money_showcase: CurrentMoneyShowcase = $PlayerSpecificHUD/CurrentMoneyShowcase
@onready var in_match_stats_showcase: InMatchStatsShowcase = $PlayerSpecificHUD/VBoxContainer/InMatchStatsShowcase

func _ready() -> void:
	super()
	current_turn_phase = TurnPhase.BEFORE_START
	var all_characters: Array[CharacterBase] = get_all_characters(true, false)
	
	for character: CharacterBase in all_characters:
		character.request_revive.connect(_handle_revive)
	
	in_match_stats_showcase.update_characters(get_characters_in_team(Enums.Team.GOOD, false), get_characters_in_team(Enums.Team.EVIL, false))
	
	TurnChoosingManager.action_choosing_interface = action_choosing_interface
	TurnChoosingManager.action_choosing_character_switchers_container = action_choosing_character_switchers_container
	
	TurnChoosingManager.choosing_start.connect(action_choosing_started)
	TurnChoosingManager.choosing_advance.connect(reveal_as_needed)
	TurnChoosingManager.choosing_end.connect(action_choosing_ended)
	
	TurnResolutionManager.resolution_started.connect(resolution_started)
	TurnResolutionManager.resolution_advance.connect(resolution_advance)
	TurnResolutionManager.resolution_ended.connect(resolution_ended)
	
	advance_turn_phase()


func switch_character_choosing_actions(character: CharacterBase) -> void:
	current_money_showcase.money_handler = character.money_handler_component
	action_choosing_interface.set_character(character)

func _handle_revive(character: CharacterBase) -> void:
	character.revive(Vector2(0, -500))

func action_choosing_started(team: Enums.Team) -> void:
	if current_turn_phase._value == 0:
		if last_turn_phase != TurnPhase.BEFORE_START:
			game_length += 1
		if game_length % 2 == 0:
			summon_minions()
	enable_team(team)
	disable_team(Enums.Team.EVIL if team == Enums.Team.GOOD else Enums.Team.GOOD if team == Enums.Team.EVIL else Enums.Team.NULL)
	reveal_as_needed(team)
	action_choosing_interface.visible = true
	update_healthbars_enemy_status(team)

func action_choosing_ended(_team: Enums.Team) -> void:
	advance_turn_phase()

func resolution_started(team: Enums.Team) -> void:
	enable_team(team)
	disable_team(Enums.Team.EVIL if team == Enums.Team.GOOD else Enums.Team.GOOD if team == Enums.Team.EVIL else Enums.Team.NULL)
	reveal_as_needed(team)
	action_choosing_interface.visible = false
	update_healthbars_enemy_status(team)

func resolution_advance(team: Enums.Team, _frame_count: int) -> void:
	reveal_as_needed(team)

func resolution_ended(_team: Enums.Team) -> void:
	advance_turn_phase()

func summon_minions() -> void:
	var new_minion: Minion = Minion.create(Enums.Team.GOOD)
	new_minion.global_position = get_enemy_base_position(Enums.Team.EVIL)
	minions.add_child(new_minion)
	
	new_minion = Minion.create(Enums.Team.EVIL)
	new_minion.global_position = get_enemy_base_position(Enums.Team.GOOD)
	minions.add_child(new_minion)

func entity_died(entity: EntityBase) -> void:
	print(entity.get_display_name(), " has died!")
	var enemy_characters: Array[CharacterBase] = get_characters_in_team(Enums.Team.EVIL if entity.my_team == Enums.Team.GOOD else Enums.Team.GOOD if entity.my_team == Enums.Team.EVIL else Enums.Team.NONE if entity.my_team == Enums.Team.NONE else Enums.Team.NULL)
	if not enemy_characters.is_empty():
		if entity is TowerBase:
			for character: CharacterBase in enemy_characters:
				character.money_handler_component.add_money(entity.get_total_money_dropped() / enemy_characters.size())
		elif entity is Minion or entity is CharacterBase: # share minion and 
			var contribution_sum: float = 0
			for character: CharacterBase in enemy_characters:
				if character.get_bounty_collection_radius() >= character.global_position.distance_to(entity.global_position) or entity is Minion:
					contribution_sum += kill_distance_contribution_buckets.get_output(character.global_position.distance_to(entity.global_position))
			
			for character: CharacterBase in enemy_characters:
				if character.get_bounty_collection_radius() >= character.global_position.distance_to(entity.global_position):
					if entity is CharacterBase:
						character.money_handler_component.add_money(CHARACTER_KILL_SECURED_MONEY*entity.get_total_money_dropped()*(kill_distance_contribution_buckets.get_output(character.global_position.distance_to(entity.global_position))/contribution_sum), true)
						character.money_handler_component.add_money((1-CHARACTER_KILL_SECURED_MONEY)*entity.get_total_money_dropped()*(kill_distance_contribution_buckets.get_output(character.global_position.distance_to(entity.global_position))/contribution_sum), false)
					else:
						character.money_handler_component.add_money(entity.get_total_money_dropped()*(kill_distance_contribution_buckets.get_output(character.global_position.distance_to(entity.global_position))/contribution_sum))
		else: # basically if kills jungle enemy / good catch-all type thing.
			var closest_character: CharacterBase = null
			var closest_distance: float = INF
			for character: CharacterBase in enemy_characters:
				if character.get_bounty_collection_radius() >= character.global_position.distance_to(entity.global_position):
					if character.global_position.distance_to(entity.global_position) < closest_distance:
						closest_character = character
						closest_distance = closest_character.global_position.distance_to(entity.global_position)
			if closest_character:
				closest_character.money_handler_component.add_money(entity.get_total_money_dropped(), false)

func advance_turn_phase() -> void:
	if not current_turn_phase.is_choose_phase() and game_length > 0:
		is_between_turns = true
		after_resolution_blocker.visible = true
		
		await get_tree().create_timer(1, true, false, true).timeout
		
		after_resolution_blocker.visible = false
		is_between_turns = false
	if current_turn_phase.get_team() != current_turn_phase.get_next().get_team():
		is_between_turns = true
		between_players_blocker.visible = true
		between_players_label.text = Enums.Team.keys()[current_turn_phase.get_next().get_team()] + " PLAYER'S TURN\nPRESS ANY BUTTON TO CONTINUE"
		
		await self.any_button_pressed
		
		between_players_blocker.visible = false
		is_between_turns = false
	last_turn_phase = current_turn_phase
	current_turn_phase = current_turn_phase.get_next()
	if (current_turn_phase.is_choose_phase()):
		TurnChoosingManager.start_choosing(current_turn_phase.get_team())
		minimap.my_team = current_turn_phase.get_team()
	else:
		TurnResolutionManager.resolution_start(current_turn_phase.get_team())
		minimap.my_team = current_turn_phase.get_team()
	if get_characters_in_team(current_turn_phase.get_team()).size() == 0 and current_turn_phase.is_choose_phase():
		TurnChoosingManager._end_choosing()

func get_all_visible_characters(team: Enums.Team, alive_only: bool = true) -> Array[CharacterBase]:
	var current_teams_characters: Array[CharacterBase] = get_characters_in_team(team, alive_only)
	
	var all_visible_characters: Array[CharacterBase] = []
	
	for character: CharacterBase in current_teams_characters:
		all_visible_characters.append(character)
		for enemy: EntityBase in character.get_visible_enemies():
			if enemy is CharacterBase and enemy not in all_visible_characters:
				all_visible_characters.append(enemy)
	
	return all_visible_characters.filter(func(c: CharacterBase) -> bool: return c.is_alive() or not alive_only)

func get_all_visible_entities(team: Enums.Team, alive_only: bool = true) -> Array[EntityBase]:
	var current_team_entities: Array[EntityBase] = get_entities_in_team(team, alive_only)
	
	var all_visible_entities: Array[EntityBase] = []
	
	for entity: EntityBase in current_team_entities:
		all_visible_entities.append(entity)
		for enemy: EntityBase in entity.get_visible_enemies():
			if enemy not in all_visible_entities:
				all_visible_entities.append(enemy)
	
	return all_visible_entities

func get_all_characters(force_update: bool = false, alive_only: bool = true) -> Array[CharacterBase]:
	if characters_by_team.is_empty() or force_update:
		characters_by_team = {
			Enums.Team.GOOD : CharacterArray.new(),
			Enums.Team.EVIL : CharacterArray.new()
		}
		for node: Node in get_tree().get_nodes_in_group("Characters"):
			if node is CharacterBase:
				characters_by_team.get(node.my_team).array.append(node)
	return (characters_by_team.get(Enums.Team.GOOD).array + characters_by_team.get(Enums.Team.EVIL).array).filter(func(c: CharacterBase) -> bool: return c.is_alive() or not alive_only)

func get_all_entities(alive_only: bool = true) -> Array[EntityBase]:
	return get_entities_in_team(Enums.Team.NONE, alive_only)

func get_entities_in_team(team: Enums.Team, alive_only: bool = true) -> Array[EntityBase]:
	if team == Enums.Team.NULL:
		return []
	if team == Enums.Team.NONE:
		@warning_ignore("confusable_local_declaration")
		var result: Array[EntityBase] = []
		@warning_ignore("confusable_local_declaration")
		var temp: Array[Node] = get_tree().get_nodes_in_group("Entities").filter(func(n: Node) -> bool: return n is EntityBase)
		for node: Node in temp:
			if node is EntityBase:
				result.append(node)
		return result.filter(func(c: EntityBase) -> bool: return c.is_alive() or not alive_only)
	
	var result: Array[EntityBase] = []
	var temp: Array[Node] = get_tree().get_nodes_in_group("Entities").filter(func(n: Node) -> bool: return n is EntityBase)
	for node: Node in temp:
		if node is EntityBase:
			result.append(node)
	result = result.filter(func(e: EntityBase) -> bool: return e.my_team == team) # filter for this team
	return result.filter(func(c: EntityBase) -> bool: return c.is_alive() or not alive_only) # filter for alive

func get_characters_in_team(team: Enums.Team, alive_only: bool = true) -> Array[CharacterBase]:
	if team == Enums.Team.NONE:
		return get_all_characters(alive_only)
	get_all_characters(alive_only)
	return (characters_by_team.get(team).array).filter(func(c: CharacterBase) -> bool: return c.is_alive() or not alive_only)

func get_camera() -> ControllableCamera:
	return $ControllableCamera

func get_enemy_base_position(team: Enums.Team) -> Vector2:
	if team == Enums.Team.EVIL:
		return $BaseMarkers/GoodBase.global_position
	elif team == Enums.Team.GOOD:
		return $BaseMarkers/EvilBase.global_position
	return Vector2.ZERO
