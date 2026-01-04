extends GameRoot
class_name TestingRoot

func _ready() -> void:
	super()
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
	if Input.is_action_just_pressed("ui_accept"):
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
	var current_teams_characters: Array[CharacterBase] = []
	
	for node: Node in get_tree().get_nodes_in_group("Characters"):
		if node is CharacterBase:
			if team == Enums.Team.NONE or node.my_team == team:
				current_teams_characters.append(node)
	
	var all_visible_characters: Array[CharacterBase] = []
	
	for character: CharacterBase in current_teams_characters:
		all_visible_characters.append(character)
		for enemy: CharacterBase in character.get_visible_enemies():
			if enemy not in all_visible_characters:
				all_visible_characters.append(enemy)
	
	return all_visible_characters

func get_all_characters() -> Array[CharacterBase]:
	var all_characters: Array[CharacterBase] = []
	for node: Node in get_tree().get_nodes_in_group("Characters"):
		if node is CharacterBase:
			all_characters.append(node)
	return all_characters
