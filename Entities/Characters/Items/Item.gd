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

@abstract
func get_item_icon() -> Texture2D


func bigger_than(another: Item) -> bool:
	if self.get_item_tier().get_ordinality() != another.get_item_tier().get_ordinality():
		return self.get_item_tier().get_ordinality() > another.get_item_tier().get_ordinality()
	return get_name_of(self.get_script()) > get_name_of(another.get_script())
## compares to another item, firstly based on tier, then name. 

static func get_name_of(input: Variant) -> String:
	if input is GDScript:
		if "ITEM_NAME" in input:
			return input.ITEM_NAME
		# Note: This version can't see the filename easily unless 
		# the script is a global class_name
		return input.get_global_name()
	elif input is Item:
		return get_name_of(input.get_script())
	else:
		return "null"
