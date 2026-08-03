extends TextureButton
class_name ItemInInventory


static func create(given_item: Item = ItemsManager.get_item("ItemNone"), given_index: int = 0) -> ItemInInventory:
	var temp: ItemInInventory = ItemInInventory.new()
	temp.my_index = given_index
	temp.set_item(given_item)
	temp.pressed.connect(temp.self_pressed)
	return temp


var my_item: Item
var my_index: int

signal was_pressed(button: ItemInInventory, item: Item, index: int)

func self_pressed() -> void:
	was_pressed.emit(self, my_item, my_index)

func disable() -> void:
	self.disabled = true

func enable() -> void:
	self.disabled = false

func set_item(given_item: Item) -> void:
	texture_normal = given_item.get_item_icon()
	my_item = given_item
