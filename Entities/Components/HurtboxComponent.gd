extends Area2D
class_name HurtboxComponent

signal got_hit(attack: Attack)
signal revealed()

var owner_entity: EntityBase

var is_enabled: bool = true
@export var my_team: Enums.Team = Enums.Team.NONE:
	set(value):
		my_team = value
		if value == Enums.Team.NONE:
			set_collision_layer_value(2, true)
			set_collision_layer_value(3, false)
			set_collision_layer_value(4, false)
		elif value == Enums.Team.GOOD:
			set_collision_layer_value(2, false)
			set_collision_layer_value(3, true)
			set_collision_layer_value(4, false)
		else:
			set_collision_layer_value(2, false)
			set_collision_layer_value(3, false)
			set_collision_layer_value(4, true)

func get_owning_entity() -> EntityBase:
	return owner_entity

func reveal() -> void:
	revealed.emit()

func you_got_entered(attack: Attack) -> void:
	got_hit.emit(attack)
