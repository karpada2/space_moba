extends Node
class_name HealthComponent

signal health_changed(new_health: int, new_max_health: int)
signal died()
signal revived()

@export var max_health: float = 600
@export var curr_health: float = 600

func deal_damage(amount: float) -> void:
	curr_health -= amount
	health_changed.emit(curr_health, max_health)
	if curr_health <= 0:
		curr_health = 0
		died.emit()
