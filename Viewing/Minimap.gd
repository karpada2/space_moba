extends SubViewport
class_name Minimap

@export var my_team: Enums.Team = Enums.Team.GOOD

func _ready() -> void:
	world_2d = get_tree().root.world_2d
