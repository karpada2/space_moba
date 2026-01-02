extends Node
class_name HealthComponent

signal health_changed(new_health: int)
signal died()
signal revived()

@export var max_health: float = 600
@export var curr_health: float = 600
