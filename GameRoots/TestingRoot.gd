extends GameRoot
class_name TestingRoot

class CharacterArray extends Object:
	var array: Array[CharacterBase]

var characters_by_team: Dictionary[Enums.Team, CharacterArray] = {}

func _ready() -> void:
	super()
	get_all_characters()
	TurnResolutionManager.resolution_started.connect(resolution_started)
	TurnResolutionManager.resolution_advance.connect(advance)

func resolution_started(team: Enums.Team) -> void:
	print(Enums.Team.find_key(team))
	get_tree().call_group("Characters", "unreveal")
	for node: Node in get_tree().get_nodes_in_group("Characters"):
		if node is CharacterBase and node.my_team == team:
			(node as CharacterBase).reveal_visible_enemies()

func advance(team: Enums.Team, _frame_count: int) -> void:
	var node: Node = get_tree().get_first_node_in_group("Characters")
	if Input.is_action_pressed("ui_accept"):
		if node is Node2D:
			node.global_position = get_global_mouse_position()
	
	var all_characters: Array[CharacterBase] = get_all_characters()
	
	var visible_characters: Array[CharacterBase] = get_all_visible_characters(team)
	
	for character: CharacterBase in all_characters:
		if character in visible_characters:
			character.reveal()
		else:
			character.unreveal()

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
		return []
	get_all_characters()
	return characters_by_team.get(team).array
