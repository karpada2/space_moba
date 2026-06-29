extends Resource
class_name ItemMap

var map: Dictionary[String, Item]

static func create(map_in: Dictionary[String, Item]) -> ItemMap:
	var newItemMap: ItemMap = ItemMap.new()
	newItemMap.map = map_in
	
	return newItemMap
