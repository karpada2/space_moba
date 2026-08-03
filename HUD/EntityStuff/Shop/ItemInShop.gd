extends TextureButton
class_name ItemInShop

static func create(given_item: Item = ItemsManager.get_item("ItemNone")) -> ItemInShop:
	var temp: ItemInShop = ItemInShop.new()
	temp.set_item(given_item)
	temp.pressed.connect(temp.self_pressed)
	return temp


var my_item: Item
var is_owned: bool = false

signal was_pressed(item: Item, is_owned_out: bool)

func self_pressed() -> void:
	was_pressed.emit(my_item, is_owned)

func set_item(given_item: Item) -> void:
	texture_normal = given_item.get_item_icon()
	my_item = given_item
