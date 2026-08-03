extends Resource
class_name ModifiedNumber

var base: float
var number_modifiers: Array[NumberModifier]

static func create(base_in: float, number_modifiers_in: Array[NumberModifier] = []) -> ModifiedNumber:
	var temp: ModifiedNumber = ModifiedNumber.new()
	temp.base = base_in
	temp.number_modifiers = number_modifiers_in
	return temp

func add_modifier(modifier: NumberModifier) -> ModifiedNumber:
	number_modifiers.append(modifier)
	return self

func get_total() -> float:
	var total_modifier: NumberModifier = NumberModifier.create()
	for modifier: NumberModifier in number_modifiers:
		total_modifier = total_modifier.add_modifier(modifier)
	
	return total_modifier.get_total(base)
