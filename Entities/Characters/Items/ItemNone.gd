extends Item
class_name ItemNone

func get_item_priority() -> int:
	return 0

func get_item_tier() -> ItemTier:
	return ItemTier.BASIC

func apply_on_attack(attack: Attack, _is_mine: bool) -> Attack:
	return attack

func apply_on_character_stats(character_stats: CharacterStats, _is_mine: bool) -> CharacterStats:
	return character_stats

func get_item_icon() -> Texture2D:
	return preload("res://Entities/Characters/Items/ItemNone.png")
