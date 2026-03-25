extends Resource
class_name ActionArray

var array: Array[Action]

static func create(array_in: Array[Action]) -> ActionArray:
	var newActionArray: ActionArray = ActionArray.new()
	newActionArray.array = array_in
	
	return newActionArray
