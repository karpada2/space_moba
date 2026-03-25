extends Node
class_name GettingHitManagerComponent

var health_component: HealthComponent
var hurtbox_component: HurtboxComponent

## called by parent, signals that this node's depndencies have been fulfilled
func you_are_ready() -> void:
	pass

func attack(attack_param: Attack) -> void:
	health_component.deal_damage(attack_param.damage_amount)
