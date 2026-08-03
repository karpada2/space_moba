extends Resource
class_name ItemTier

static var BASIC: ItemTier = ItemTier._create(500, "Basic", 1)
static var ADVANCED: ItemTier = ItemTier._create(1000, "Advanced", 2)
static var MASTER: ItemTier = ItemTier._create(2000, "Master", 3)

var _cost: int
var _rarity_name: String
var _ordinality: int

static func _create(cost_in: int, rarity_name: String, ordinality: int) -> ItemTier:
	var new_tier: ItemTier = ItemTier.new()
	
	new_tier._cost = cost_in
	new_tier._rarity_name = rarity_name
	new_tier._ordinality = ordinality
	
	return new_tier

func get_ordinality() -> int:
	return _ordinality

func get_cost() -> int:
	return _cost

func get_rarity_name() -> String:
	return _rarity_name
