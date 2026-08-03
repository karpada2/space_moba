extends Resource
class_name Attack

var _damage_amount: ModifiedNumber
var _damage_type: Enums.DamageType


static func create(damage_amount: float, damage_type: Enums.DamageType) -> Attack:
	var new_attack: Attack = Attack.new()
	
	new_attack._damage_amount = ModifiedNumber.create(damage_amount)
	new_attack._damage_type = damage_type
	
	return new_attack

func _clone_inner() -> Attack:
	var new_attack: Attack = self._new_inner()
	
	return new_attack

func _new_inner() -> Attack:
	return Attack.new()

func clone() -> Attack:
	var new_attack: Attack = self._clone_inner()
	
	new_attack._damage_amount = self._damage_amount
	new_attack._damage_type = self._damage_type
	
	return new_attack

func get_damage(_attackee: EntityBase) -> float:
	#TODO: actually implement resistances and shit
	return _damage_amount.get_total()
