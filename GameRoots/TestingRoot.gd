extends GameRoot
class_name TestingRoot

var characters_by_team: Dictionary[Enums.Team, CharacterArray] = {}
@onready var navigation_region_2d: NavigationRegion2D = $NavigationRegion2D

@onready var action_choosing_interface: ActionChoosingInterface = $ActionChoosers/VBoxContainer/ActionChoosingInterface
@onready var action_choosing_character_switchers_container: HBoxContainer = $ActionChoosers/VBoxContainer/ActionChoosingCharacterSwitchers

func _ready() -> void:
	super()
	current_turn_phase = TurnPhase.EVIL_TEAM_RESOLVE
	get_all_characters()
	
	TurnChoosingManager.action_choosing_interface = action_choosing_interface
	TurnChoosingManager.action_choosing_character_switchers_container = action_choosing_character_switchers_container
	
	TurnChoosingManager.choosing_start.connect(action_choosing_started)
	TurnChoosingManager.choosing_end.connect(action_choosing_ended)
	
	TurnResolutionManager.resolution_started.connect(resolution_started)
	TurnResolutionManager.resolution_advance.connect(resolution_advance)
	TurnResolutionManager.resolution_ended.connect(resolution_ended)

var has_started: bool = false

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept") and !has_started:
		print("haha!")
		advance_turn_phase()
		has_started = true

func action_choosing_started(team: Enums.Team) -> void:
	reveal_as_needed(team)

func action_choosing_ended(_team: Enums.Team) -> void:
	advance_turn_phase()

func resolution_started(team: Enums.Team) -> void:
	reveal_as_needed(team)

func resolution_advance(team: Enums.Team, _frame_count: int) -> void:
	reveal_as_needed(team)

func resolution_ended() -> void:
	advance_turn_phase()

func advance_turn_phase() -> void:
	current_turn_phase = current_turn_phase.get_next()
	if (current_turn_phase.is_choose_phase()):
		TurnChoosingManager.start_choosing(current_turn_phase.get_team())
	else:
		TurnResolutionManager.resolution_start(current_turn_phase.get_team())

func get_all_visible_characters(team: Enums.Team) -> Array[CharacterBase]:
	var current_teams_characters: Array[CharacterBase] = get_characters_in_team(team)
	
	var all_visible_characters: Array[CharacterBase] = []
	
	for character: CharacterBase in current_teams_characters:
		all_visible_characters.append(character)
		for enemy: CharacterBase in character.get_visible_enemies():
			if enemy not in all_visible_characters:
				all_visible_characters.append(enemy)
	
	return all_visible_characters

func get_all_characters(force_update: bool = false) -> Array[CharacterBase]:
	if characters_by_team.is_empty() or force_update:
		characters_by_team = {
			Enums.Team.GOOD : CharacterArray.new(),
			Enums.Team.EVIL : CharacterArray.new()
		}
		for node: Node in get_tree().get_nodes_in_group("Characters"):
			if node is CharacterBase:
				characters_by_team.get(node.my_team).array.append(node)
	return characters_by_team.get(Enums.Team.GOOD).array + characters_by_team.get(Enums.Team.EVIL).array

func get_characters_in_team(team: Enums.Team) -> Array[CharacterBase]:
	if team == Enums.Team.NONE:
		return get_all_characters()
	get_all_characters()
	return characters_by_team.get(team).array
