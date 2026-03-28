extends Node
class_name HealthComponent

signal health_changed(new_health: int, new_max_health: int)
signal died()
signal revived()

var is_alive: bool = true

@export var max_health: float = 600:
	set(value):
		if value > 0:
			max_health = value
			curr_health = minf(curr_health, max_health)
@export var curr_health: float = 600:
	set(value):
		if value <= 0:
			health_changed.emit(0, max_health)
			if curr_health > 0:
				is_alive = false
				died.emit()
			curr_health = 0
		else:
			if is_alive:
				curr_health = minf(value, max_health)
				health_changed.emit(curr_health, max_health)
			else:
				is_alive = true
				curr_health = minf(value, max_health)
				health_changed.emit(curr_health, max_health)
				revived.emit()

func deal_damage(amount: float) -> void:
	curr_health -= amount

func heal(amount: float) -> void:
	curr_health += amount
