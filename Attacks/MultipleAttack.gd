extends Attack
class_name MultipleAttack

var sub_attacks: Array[Attack]

func _new_inner() -> MultipleAttack:
	return MultipleAttack.new()

func clone() -> MultipleAttack:
	var new_attack: MultipleAttack = self._clone_inner()
	
	new_attack.sub_attacks = self.sub_attacks.duplicate_deep()
	
	return new_attack

func get_damage(attackee: EntityBase) -> float:
	var damage_sum: float = 0
	for attack: Attack in sub_attacks:
		damage_sum += attack.get_damage(attackee)
	return damage_sum
