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

func get_sub_attacks(deep: bool = false) -> Array[Attack]:
	if not deep:
		return sub_attacks
	var return_result: Array[Attack] = []
	for attack: Attack in sub_attacks:
		if attack is MultipleAttack:
			return_result.append_array(get_sub_attacks(deep))
		elif attack is BasicAttack:
			return_result.append(attack)
	
	return return_result

func apply_number_modifier(modifier: ModifiedNumber) -> void:
	for attack: Attack in sub_attacks:
		attack.apply_number_modifier(modifier)
