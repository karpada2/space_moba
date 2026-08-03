extends Node

var item_map: ItemMap = ItemMap.create({}) # String ID -> Instance
var item_none: ItemNone = preload("res://Entities/Characters/Items/ItemNone.gd").new()

var weapon_items: Dictionary[ItemTier, ItemMap] = {
		ItemTier.BASIC: ItemMap.create({}),
		ItemTier.ADVANCED: ItemMap.create({}),
		ItemTier.MASTER: ItemMap.create({}),
	}
var vitality_items: Dictionary[ItemTier, ItemMap] = {
		ItemTier.BASIC: ItemMap.create({}),
		ItemTier.ADVANCED: ItemMap.create({}),
		ItemTier.MASTER: ItemMap.create({}),
	}
var magic_items: Dictionary[ItemTier, ItemMap] = {
		ItemTier.BASIC: ItemMap.create({}),
		ItemTier.ADVANCED: ItemMap.create({}),
		ItemTier.MASTER: ItemMap.create({}),
	}

func _ready() -> void:
	var paths: Array[String] = ["res://Entities/Characters/Items/WeaponItems/", "res://Entities/Characters/Items/VitalityItems/", "res://Entities/Characters/Items/MagicItems/"]
	for p: String in paths:
		_scan_dir(p)

func _scan_dir(path: String) -> void:
	var dir: DirAccess = DirAccess.open(path)
	if not dir: return
	
	dir.list_dir_begin()
	var file: String = dir.get_next()
	
	while file != "":
		if file.ends_with(".gd"):
			var script: Resource = load(path + file)
			# Godot 4.4+ native check for abstract
			if script is GDScript and not script.is_abstract():
				var inst: Resource = script.new()
				if inst is Item:
					var item_name: String = Item.get_name_of(script)
					# Store by class_name or file_name for easy lookup
					item_map.map[item_name] = inst
					if inst is WeaponItem:
						weapon_items[inst.get_item_tier()].map[item_name] = inst
					elif inst is VitalityItem:
						vitality_items[inst.get_item_tier()].map[item_name] = inst
					elif inst is MagicItem:
						magic_items[inst.get_item_tier()].map[item_name] = inst
				
		file = dir.get_next()

func get_item(id: String) -> Item:
	if item_map.map.has(id):
		return item_map.map.get(id).clone()
	return item_none.clone()
