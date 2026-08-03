extends Resource
class_name AttackResultInfo

var damage_done: float
var damage_type: Enums.DamageType
var attacker: EntityBase
var attackee: EntityBase
var conditions_inflicted: Array[ConditionBase]

static func create(damage_done_in: float, damage_type_in: Enums.DamageType, attacker_in: EntityBase, attackee_in: EntityBase, conditions_inflicted_in: Array[ConditionBase]) -> AttackResultInfo:
	var temp: AttackResultInfo = AttackResultInfo.new()
	temp.damage_done = damage_done_in
	temp.damage_type = damage_type_in
	temp.attacker = attacker_in
	temp.attackee = attackee_in
	temp.conditions_inflicted = conditions_inflicted_in
	return temp
