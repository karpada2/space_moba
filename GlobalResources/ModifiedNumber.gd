extends Resource
class_name ModifiedNumber

var base: float
var addition: float
var multiplier: float

static func create(base_in: float, addition_in: float = 0, multiplier_in: float = 1) -> ModifiedNumber:
	var new_modified_number: ModifiedNumber = ModifiedNumber.new()
	
	new_modified_number.base = base_in
	new_modified_number.addition = addition_in
	new_modified_number.multiplier = multiplier_in
	
	return new_modified_number

func clone() -> ModifiedNumber:
	return ModifiedNumber.create(self.base, self.addition, self.multiplier)

func add_bonus(bonus: float) -> ModifiedNumber:
	self.addition += bonus
	return self

# adds (added_multiplier - 1) to the multiplier, unless remove_one is false in which case just adds added_multiplier
func add_multiplier(added_multiplier: float, remove_one: bool = false) -> ModifiedNumber:
	self.multiplier += added_multiplier if not remove_one else (added_multiplier - 1)
	return self

func get_total() -> float:
	if multiplier <= 0:
		return 0
	
	return (base + addition)*multiplier
