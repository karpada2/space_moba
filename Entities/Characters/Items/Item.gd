@abstract
extends Resource
class_name Item

@abstract
func get_item_tier() -> ItemTier

func get_price() -> int:
	return get_item_tier().get_cost()

@abstract
## what affects the entity with the item, when ATTACKING with this attack, with the corresponding result (from the other entity)
## meant for offensive, on-hit effects (like tankbuster, mercurial magnum from deadlock)
func get_attacking_stat_affecter(attack: Attack, attack_result_info: AttackResultInfo) -> StatAffecter

@abstract
## what affects the entity with the item, when BEING ATTACKED by this attack, with the corresponding result (from this entity)
## meant for defensive, on-hit effects (like berserker, spellbreaker from deadlock)
func get_attacked_stat_affecter(attack: Attack, attack_result_info: AttackResultInfo) -> StatAffecter

@abstract
## what ALWAYS affects the entity with the item (also weird cases (if in water, at night, etc.), actives, etc.)
func get_normal_stat_affecter() -> StatAffecter

@abstract
func get_item_icon() -> Texture2D

@abstract
func clone() -> Item

func equals(another: Item) -> bool:
	return another.get_script() == self.get_script()

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
