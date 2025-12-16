extends Node
class_name HealthComponent

signal health_changed(new_health: int)
signal died()
signal revived()

var a: DamageTypes.Type = DamageTypes.Type.MAGICAL
@export var max_health: float = 600
@export var curr_health: float = 600
