extends MagicItem
class_name MagicalRings

const ITEM_NAME: String = "Magical Ring"

func get_item_tier() -> ItemTier:
	return ItemTier.BASIC

func get_attacked_stat_affecter(_attack: Attack, _attack_result_info: AttackResultInfo) -> StatAffecter:
	return DummyStatAffecter.new()

func get_attacking_stat_affecter(_attack: Attack, _attack_result_info: AttackResultInfo) -> StatAffecter:
	return DummyStatAffecter.new()

func get_normal_stat_affecter() -> StatAffecter:
	return SimpleStatAffecter.create(Enums.EntityStats.MAGICAL_PROWESS, NumberModifier.create(5))

func clone() -> Item:
	return self

func get_item_icon() -> Texture2D:
	return preload("res://Entities/Characters/Items/MagicItems/MagicalRings.png")
