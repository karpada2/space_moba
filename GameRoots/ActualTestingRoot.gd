extends Node2D

@onready var add_items_buttons: HBoxContainer = $CanvasLayer/VBoxContainer/AddItemsButtons
@onready var inventory: Inventory = $CanvasLayer/VBoxContainer/Inventory

func _ready() -> void:
	var curr_item_in_inventory: ItemInInventory
	for item_name: String in ItemsManager.item_map.map.keys():
		curr_item_in_inventory = ItemInInventory.create(ItemsManager.get_item(item_name))
		curr_item_in_inventory.enable()
		curr_item_in_inventory.was_pressed.connect(want_add_item)
		add_items_buttons.add_child(curr_item_in_inventory)

func want_add_item(_button: ItemInInventory, item: Item, _index: int) -> void:
	inventory.add_item(item)
