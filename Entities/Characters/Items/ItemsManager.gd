extends Node

var item_map: ItemMap = ItemMap.create({}) # String ID -> Instance

var weapon_items: Dictionary[ItemTier, ItemMap] = {}
var vitality_items: Dictionary[ItemTier, ItemMap] = {}
var magic_items: Dictionary[ItemTier, ItemMap] = {}

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
			if script is GDScript and script.can_instantiate():
				var inst: Resource = script.new()
				if inst is Item:
					# Store by class_name or file_name for easy lookup
					item_map.map[inst.get_item_name()] = inst
					if inst is WeaponItem:
						weapon_items[inst.get_item_tier()].map[inst.get_item_name()] = inst
					elif inst is VitalityItem:
						vitality_items[inst.get_item_tier()].map[inst.get_item_name()] = inst
					elif inst is MagicItem:
						magic_items[inst.get_item_tier()].map[inst.get_item_name()] = inst
				
		file = dir.get_next()

func get_item(id: String) -> Item:
	return item_map.get(id)
