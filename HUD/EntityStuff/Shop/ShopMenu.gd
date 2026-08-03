extends Control
class_name ShopMenu

signal request_close_shop()

@onready var basic_weapon_items_container: HFlowContainer = $TabContainer/Weapon/VBoxContainer/BasicWeaponItemsContainer
@onready var advanced_weapon_items_container: HFlowContainer = $TabContainer/Weapon/VBoxContainer/AdvancedWeaponItemsContainer
@onready var master_weapon_items_container: HFlowContainer = $TabContainer/Weapon/VBoxContainer/MasterWeaponItemsContainer

@onready var basic_vitality_items_container: HFlowContainer = $TabContainer/Vitality/VBoxContainer/BasicVitalityItemsContainer
@onready var advanced_vitality_items_container: HFlowContainer = $TabContainer/Vitality/VBoxContainer/AdvancedVitalityItemsContainer
@onready var master_vitality_items_container: HFlowContainer = $TabContainer/Vitality/VBoxContainer/MasterVitalityItemsContainer

@onready var basic_magic_items_container: HFlowContainer = $TabContainer/Magic/VBoxContainer/BasicMagicItemsContainer
@onready var advanced_magic_items_container: HFlowContainer = $TabContainer/Magic/VBoxContainer/AdvancedMagicItemsContainer
@onready var master_magic_items_container: HFlowContainer = $TabContainer/Magic/VBoxContainer/MasterMagicItemsContainer


@onready var close_shop_button: Button = $CloseShopButton

func enable() -> void:
	show()
	mouse_filter = Control.MOUSE_FILTER_STOP
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_ENABLED
	for node: Control in all_children:
		node.mouse_filter = Control.MOUSE_FILTER_STOP

func disable() -> void:
	hide()
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	for node: Control in all_children:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE

var all_children: Array[Control]

func _ready() -> void:
	for node: Node in find_children("*", "", true, false):
		if node is Control:
			all_children.append(node)
	close_shop_button.pressed.connect(request_close_shop.emit)
	
	var shop_containers: Array[HFlowContainer] = [
		basic_weapon_items_container,
		advanced_weapon_items_container,
		master_weapon_items_container,
		basic_vitality_items_container,
		advanced_vitality_items_container,
		master_vitality_items_container,
		basic_magic_items_container,
		advanced_magic_items_container,
		master_magic_items_container
	]
	var item_names: Array[Array] = [
		ItemsManager.weapon_items[ItemTier.BASIC].map.keys(),
		ItemsManager.weapon_items[ItemTier.ADVANCED].map.keys(),
		ItemsManager.weapon_items[ItemTier.MASTER].map.keys(),
		ItemsManager.vitality_items[ItemTier.BASIC].map.keys(),
		ItemsManager.vitality_items[ItemTier.ADVANCED].map.keys(),
		ItemsManager.vitality_items[ItemTier.MASTER].map.keys(),
		ItemsManager.magic_items[ItemTier.BASIC].map.keys(),
		ItemsManager.magic_items[ItemTier.ADVANCED].map.keys(),
		ItemsManager.magic_items[ItemTier.MASTER].map.keys()
	]
	
	var new_button: ItemInShop
	for category: int in item_names.size():
		for item_name: String in item_names[category]:
			new_button = ItemInShop.create(ItemsManager.get_item(item_name))
			new_button.was_pressed.connect(handle_press_on_item)
			shop_containers[category].add_child(new_button)

func set_inventory(inventory: Inventory) -> void:
	pass

func handle_press_on_item(item: Item, is_owned: bool) -> void:
	print(Item.get_name_of(item))
	print(is_owned)
