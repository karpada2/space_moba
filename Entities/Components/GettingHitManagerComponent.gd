extends Node
class_name GettingHitManagerComponent

var health_component: HealthComponent
var hurtbox_component: HurtboxComponent

## called by parent, signals that this node's depndencies have been fulfilled
func you_are_ready() -> void:
	pass
