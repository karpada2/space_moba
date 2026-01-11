extends Resource
class_name PlayerActionArray

var array: Array[PlayerAction]

static func create(array_in: Array[PlayerAction]) -> PlayerActionArray:
	var newActionArray: PlayerActionArray = PlayerActionArray.new()
	newActionArray.array = array_in
	
	return newActionArray
