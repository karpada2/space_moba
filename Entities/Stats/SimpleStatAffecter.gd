extends StatAffecter
class_name SimpleStatAffecter

var affected_stat: Enums.EntityStats

var number_modifier: NumberModifier


static func create(affected_stat_in: Enums.EntityStats, number_modifier_in: NumberModifier) -> SimpleStatAffecter:
	var temp: SimpleStatAffecter = SimpleStatAffecter.new()
	temp.affected_stat = affected_stat_in
	temp.number_modifier = number_modifier_in
	return temp


func affect_stat(stat_name: Enums.EntityStats, value: ModifiedNumber) -> ModifiedNumber:
	if affected_stat == stat_name:
		return value.add_modifier(number_modifier)
	return value
