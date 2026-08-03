extends VBoxContainer
class_name Inventory

@export var row_amount: int = 2:
	set(value):
		var should_update: bool = row_amount != value
		row_amount = value
		if should_update:
			update_items_display()
@export var column_amount: int = 5:
	set(value):
		var should_update: bool = column_amount != value
		column_amount = value
		if should_update:
			update_items_display()

var rows: Array[HBoxContainer]
var items: Array[Item]

func _ready() -> void:
	update_items_display(true)

func get_item_at_index(index: int) -> Item:
	if index >= items.size():
		return ItemsManager.item_none
	return items[index]

func add_item(added_item: Item) -> void:
	var index_to_insert: int = 0
	if items.size() > 0:
		for i: int in items.size():
			if added_item.bigger_than(get_item_at_index(i)):
				index_to_insert = i + 1
	items.insert(index_to_insert, added_item)
	update_items_display()

func remove_item(item_to_remove: Item) -> void:
	remove_item_by_index(items.find(item_to_remove))

func remove_item_by_index(index_to_remove: int) -> void:
	items.remove_at(index_to_remove)
	update_items_display()

func item_pressed(button: ItemInInventory, item: Item, index: int) -> void:
	pass


var last_call_row_amount: int = -1
var last_call_column_amount: int = -1
func update_items_display(force_reset: bool = false) -> void:
	if force_reset or (last_call_row_amount == -1 or last_call_column_amount == -1) or (last_call_row_amount != row_amount or last_call_column_amount != column_amount):
		for child: Node in self.get_children():
			child.queue_free()
		rows.clear()
		
		for _i: int in row_amount:
			var hbox: HBoxContainer = HBoxContainer.new()
			for _j: int in column_amount:
				hbox.add_child(ItemInInventory.create())
			self.add_child(hbox)
			rows.append(hbox)
	
	var running_index: int = 0
	var curr_child: Node
	for column_index: int in column_amount:
		for row: HBoxContainer in rows:
			curr_child = row.get_child(column_index)
			if curr_child is ItemInInventory:
				curr_child.set_item(get_item_at_index(running_index))
				curr_child.my_index = running_index
				running_index += 1
				if not curr_child.was_pressed.is_connected(item_pressed):
					curr_child.was_pressed.connect(item_pressed)
	
	last_call_row_amount = row_amount
	last_call_column_amount = column_amount
