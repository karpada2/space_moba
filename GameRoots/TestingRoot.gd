extends GameRoot
class_name TestingRoot

func _ready() -> void:
	TurnResolutionManager.resolution_started.connect(resolution_started)

func resolution_started(team: Enums.Team) -> void:
	print(Enums.Team.find_key(team))
	get_tree().call_group("VisibleEntities", "unreveal")
	for node: Node in get_tree().get_nodes_in_group("Characters"):
		if node is CharacterBase and node.my_team == team:
			(node as CharacterBase).reveal_close_enemies()
