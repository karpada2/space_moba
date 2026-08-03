extends VBoxContainer
class_name InventoryShowcase

signal item_pressed(item: Item, index: int)

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

var pressing_enabled: bool = false:
	set(value):
		pressing_enabled = value
		update_button_enable_status()

func enable_pressing() -> void:
	pressing_enabled = true

func disable_pressing() -> void:
	pressing_enabled = false

var rows: Array[HBoxContainer]
@export var inventory: Inventory:
	set(value):
		if inventory and inventory.items_changed.is_connected(inventory_contents_changed):
			inventory.items_changed.disconnect(inventory_contents_changed)
		inventory = value
		if inventory:
			inventory.items_changed.connect(inventory_contents_changed)
		update_items_display(true)

func inventory_contents_changed() -> void:
	update_items_display()

func _ready() -> void:
	update_items_display(true)

func item_showcase_pressed(_button: ItemInInventory, item: Item, index: int) -> void:
	if pressing_enabled:
		item_pressed.emit(item, index)

func get_item_at_index(index: int) -> Item:
	if inventory:
		return inventory.get_item_at_index(index)
	return ItemsManager.item_none

func update_button_enable_status() -> void:
	for row: HBoxContainer in rows:
			for node: Node in row.get_children():
				if node is Button:
					node.disabled = !pressing_enabled

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
				if not curr_child.was_pressed.is_connected(item_showcase_pressed):
					curr_child.was_pressed.connect(item_showcase_pressed)
	
	last_call_row_amount = row_amount
	last_call_column_amount = column_amount
