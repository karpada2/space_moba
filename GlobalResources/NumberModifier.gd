extends Resource
class_name NumberModifier

var addition: float
var multiplier: float

static func create(addition_in: float = 0, multiplier_in: float = 1) -> NumberModifier:
	var new_modified_number: NumberModifier = NumberModifier.new()
	
	new_modified_number.addition = addition_in
	new_modified_number.multiplier = multiplier_in
	
	return new_modified_number

func clone() -> NumberModifier:
	return NumberModifier.create(self.addition, self.multiplier)

func add_bonus(bonus: float) -> NumberModifier:
	self.addition += bonus
	return self

# adds (added_multiplier - 1) to the multiplier, unless remove_one is false in which case just adds added_multiplier
func add_multiplier(added_multiplier: float, remove_one: bool = false) -> NumberModifier:
	self.multiplier += added_multiplier if not remove_one else (added_multiplier - 1)
	return self

func add_modifier(another: NumberModifier) -> NumberModifier:
	return clone().add_multiplier(another.multiplier).add_bonus(another.addition)

func get_total(input: float) -> float:
	return (input + addition)*multiplier
