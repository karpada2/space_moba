extends GameRoot
class_name TestingRoot

signal any_button_pressed()

var characters_by_team: Dictionary[Enums.Team, CharacterArray] = {}
@onready var navigation_region_2d: NavigationRegion2D = $WorldLayer/NavigationRegion2D

var is_between_turns: bool = false

@onready var action_choosing_interface: ActionChoosingInterface = $ActionChoosers/VBoxContainer/ActionChoosingInterface
@onready var action_choosing_character_switchers_container: HBoxContainer = $ActionChoosers/VBoxContainer/ActionChoosingCharacterSwitchers
@onready var minimap: Minimap = $Minimaps/Minimap
@onready var between_players_blocker: CanvasLayer = $BetweenPlayersBlocker
@onready var between_players_label: Label = $BetweenPlayersBlocker/Panel/Label

func _ready() -> void:
	super()
	current_turn_phase = TurnPhase.EVIL_TEAM_RESOLVE
	var all_characters: Array[CharacterBase] = get_all_characters(true, false)
	
	for character: CharacterBase in all_characters:
		character.request_revive.connect(_handle_revive)
	
	TurnChoosingManager.action_choosing_interface = action_choosing_interface
	TurnChoosingManager.action_choosing_character_switchers_container = action_choosing_character_switchers_container
	
	TurnChoosingManager.choosing_start.connect(action_choosing_started)
	TurnChoosingManager.choosing_advance.connect(reveal_as_needed)
	TurnChoosingManager.choosing_end.connect(action_choosing_ended)
	
	TurnResolutionManager.resolution_started.connect(resolution_started)
	TurnResolutionManager.resolution_advance.connect(resolution_advance)
	TurnResolutionManager.resolution_ended.connect(resolution_ended)
	
	advance_turn_phase()

func _physics_process(_delta: float) -> void:
	if Input.is_anything_pressed():
		any_button_pressed.emit()

func _handle_revive(character: CharacterBase) -> void:
	character.revive(Vector2(0, -500))

func action_choosing_started(team: Enums.Team) -> void:
	enable_team(team)
	disable_team(Enums.Team.EVIL if team == Enums.Team.GOOD else Enums.Team.GOOD if team == Enums.Team.EVIL else Enums.Team.NULL)
	reveal_as_needed(team)
	action_choosing_interface.visible = true

func action_choosing_ended(_team: Enums.Team) -> void:
	advance_turn_phase()

func resolution_started(team: Enums.Team) -> void:
	enable_team(team)
	disable_team(Enums.Team.EVIL if team == Enums.Team.GOOD else Enums.Team.GOOD if team == Enums.Team.EVIL else Enums.Team.NULL)
	reveal_as_needed(team)
	action_choosing_interface.visible = false

func resolution_advance(team: Enums.Team, _frame_count: int) -> void:
	reveal_as_needed(team)

func resolution_ended(_team: Enums.Team) -> void:
	if current_turn_phase._value == 3:
		game_length += 1
	advance_turn_phase()

func advance_turn_phase() -> void:
	if current_turn_phase.get_team() != current_turn_phase.get_next().get_team():
		is_between_turns = true
		between_players_blocker.visible = true
		between_players_label.text = Enums.Team.keys()[current_turn_phase.get_next().get_team()] + " PLAYER'S TURN\nPRESS ANY BUTTON TO CONTINUE"
		
		await self.any_button_pressed
		
		between_players_blocker.visible = false
		is_between_turns = false
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
	var current_teams_characters: Array[CharacterBase] = get_characters_in_team(team)
	
	var all_visible_characters: Array[CharacterBase] = []
	
	for character: CharacterBase in current_teams_characters:
		all_visible_characters.append(character)
		for enemy: CharacterBase in character.get_visible_enemies():
			if enemy not in all_visible_characters:
				all_visible_characters.append(enemy)
	
	return all_visible_characters.filter(func(c: CharacterBase) -> bool: return c.is_alive() or not alive_only)

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

func get_characters_in_team(team: Enums.Team, alive_only: bool = true) -> Array[CharacterBase]:
	if team == Enums.Team.NONE:
		return get_all_characters(alive_only)
	get_all_characters(alive_only)
	return (characters_by_team.get(team).array).filter(func(c: CharacterBase) -> bool: return c.is_alive() or not alive_only)

func get_camera() -> ControllableCamera:
	return $ControllableCamera
