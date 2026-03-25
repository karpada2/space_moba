extends Resource
class_name Attack


## this just represents the attack itself (damage type, amount, etc. Actual projectiles and stuff will be made in another way)
var damage_amount: float
var damage_type: Enums.DamageType

static func create(damage_amount_in: float, damage_type_in: Enums.DamageType) -> Attack:
	var temp: Attack = Attack.new()
	temp.damage_amount = damage_amount_in
	temp.damage_type = damage_type_in
	
	return temp

func clone() -> Attack:
	var new_attack: Attack = Attack.new()
	new_attack.damage_amount = self.damage_amount
	new_attack.damage_type = self.damage_type
	
	return new_attack
