extends EntityBase
class_name TowerBase

func reveal() -> void:
	pass

func unreveal() -> void:
	pass

func enable() -> void:
	reveal()

func disable() -> void:
	unreveal()

func died() -> void:
	pass

func get_move_distance_per_frame() -> float:
	return 0

func get_visible_enemies() -> Array[EntityBase]:
	return []
