@abstract
extends Resource
class_name Attack


## this just represents the attack itself (damage type, amount, etc. Actual projectiles and stuff will be made in another way)

var my_owner: EntityBase

@abstract
func clone() -> Attack

@abstract
func _new_inner() -> Attack

func _clone_inner() -> Attack:
	var new_attack: Attack = self._new_inner()
	
	new_attack.my_owner = self.my_owner
	
	return new_attack

@abstract
func get_damage(attackee: EntityBase) -> float

@abstract
func apply_number_modifier(modifier: ModifiedNumber, condition: Callable) -> void
