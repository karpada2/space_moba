extends Resource
class_name OrganizedActionArrays

var dictionary: Dictionary[String, ActionArray]

static func create(dictionary_in: Dictionary[String, ActionArray]) -> OrganizedActionArrays:
	var newOAA: OrganizedActionArrays = OrganizedActionArrays.new()
	newOAA.dictionary = dictionary_in
	
	return newOAA
