extends VitalityItem
class_name ItemBonusHealth

const ITEM_NAME: String = "More Mass"

func get_item_priority() -> int:
	return 2

func get_item_tier() -> ItemTier:
	return ItemTier.BASIC

func apply_on_attack(attack: Attack, _is_mine: bool) -> Attack:
	return attack

func apply_on_character_stats(character_stats: CharacterStats, is_mine: bool) -> CharacterStats:
	if is_mine:
		character_stats.max_health.add_bonus(100)
	return character_stats

func get_item_icon() -> Texture2D:
	return preload("res://Entities/Characters/Items/VitalityItems/BonusHealth.png")
