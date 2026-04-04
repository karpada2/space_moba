extends Attack
class_name BasicAttack

var _damage_amount: float
var _damage_type: Enums.DamageType


static func create(damage_amount: float, damage_type: Enums.DamageType, owner_in: EntityBase) -> BasicAttack:
	var new_attack: BasicAttack = BasicAttack.new()
	
	new_attack.my_owner = owner_in
	new_attack._damage_amount = damage_amount
	new_attack._damage_type = damage_type
	
	return new_attack


func _new_inner() -> BasicAttack:
	return BasicAttack.new()

func clone() -> BasicAttack:
	var new_attack: BasicAttack = self._clone_inner()
	
	new_attack._damage_amount = self._damage_amount
	new_attack._damage_type = self._damage_type
	
	return new_attack

func get_damage(_attackee: EntityBase) -> float:
	#TODO: actually implement resistances and shit
	return _damage_amount
