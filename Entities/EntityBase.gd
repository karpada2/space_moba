@abstract
extends CharacterBody2D
class_name EntityBase

@export var my_team: Enums.Team = Enums.Team.NONE

var getting_hit_manager: GettingHitManagerComponent
var health_component: HealthComponent
var hurtbox_component: HurtboxComponent

@abstract
func unreveal() -> void

func _ready() -> void:
	if my_team == Enums.Team.NONE:
		set_collision_layer_value(2, true)
		set_collision_layer_value(3, false)
		set_collision_layer_value(4, false)
	elif my_team == Enums.Team.GOOD:
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, true)
		set_collision_layer_value(4, false)
	else:
		set_collision_layer_value(2, false)
		set_collision_layer_value(3, false)
		set_collision_layer_value(4, true)
	
	for node: Node in self.get_children():
		if node is HealthComponent:
			health_component = node
		elif node is GettingHitManagerComponent:
			getting_hit_manager = node
		elif node is HurtboxComponent:
			hurtbox_component = node
	
	hurtbox_component.owner_entity = self
	hurtbox_component.my_team = self.my_team
	getting_hit_manager.health_component = self.health_component
	getting_hit_manager.hurtbox_component = self.hurtbox_component
