extends Node
class_name Inventory

signal items_changed()
signal item_removed(item: Item)

var items: Array[Item]
@export var max_size: int = 10

func get_item_at_index(index: int) -> Item:
	if index >= items.size():
		return ItemsManager.item_none
	return items[index]

func add_item(added_item: Item) -> bool:
	if items.size() < max_size:
		var index_to_insert: int = 0
		if items.size() > 0:
			for i: int in items.size():
				if added_item.bigger_than(get_item_at_index(i)):
					index_to_insert = i + 1
		items.insert(index_to_insert, added_item)
		items_changed.emit()
		return true
	return false

func remove_item(item_to_remove: Item) -> void:
	remove_item_by_index(items.find(item_to_remove))

func remove_item_by_index(index_to_remove: int) -> void:
	var removed_item: Item = items[index_to_remove]
	items.remove_at(index_to_remove)
	item_removed.emit(removed_item)
	items_changed.emit()
