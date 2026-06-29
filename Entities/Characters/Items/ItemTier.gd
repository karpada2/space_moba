extends Resource
class_name ItemTier

static var BASIC: ItemTier = ItemTier._create(500, "Basic")
static var ADVANCED: ItemTier = ItemTier._create(1000, "Advanced")
static var MASTER: ItemTier = ItemTier._create(2000, "Master")

var _item_cost: int
var _item_rarity_name: String

static func _create(item_cost_in: int, rarity_name: String) -> ItemTier:
	var new_tier: ItemTier = ItemTier.new()
	
	new_tier._item_cost = item_cost_in
	new_tier._item_rarity_name = rarity_name
	
	return new_tier

func get_cost() -> int:
	return _item_cost

func get_rarity_name() -> String:
	return _item_rarity_name
