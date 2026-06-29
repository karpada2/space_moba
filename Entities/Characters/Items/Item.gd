@abstract
extends Resource
class_name Item

# determines in what order this item affects stuff. unique is always first, then flat, then percent; within these categories priority matters.
@abstract
func get_item_priority() -> int

@abstract
func get_item_tier() -> ItemTier

func get_price() -> int:
	return get_item_tier().get_cost()

@abstract
func apply_on_attack(attack: Attack, is_mine: bool) -> Attack

@abstract
func apply_on_character_stats(character_stats: CharacterStats, is_mine: bool) -> CharacterStats

static func get_name_of(script: GDScript) -> String:
	if "ITEM_NAME" in script:
		return script.ITEM_NAME
	# Note: This version can't see the filename easily unless 
	# the script is a global class_name
	return script.get_global_name()
