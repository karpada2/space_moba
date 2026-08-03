extends WeaponItem
class_name ItemBonusDamage

const ITEM_NAME: String = "'Roided Up Arms"

func get_item_tier() -> ItemTier:
	return ItemTier.BASIC

func get_attacked_stat_affecter(_attack: Attack, _attack_result_info: AttackResultInfo) -> StatAffecter:
	return DummyStatAffecter.new()

func get_attacking_stat_affecter(_attack: Attack, _attack_result_info: AttackResultInfo) -> StatAffecter:
	return DummyStatAffecter.new()

func get_normal_stat_affecter() -> StatAffecter:
	return SimpleStatAffecter.create(Enums.EntityStats.BASIC_ATTACK_DAMAGE, NumberModifier.create(15))

func clone() -> Item:
	return self

func get_item_icon() -> Texture2D:
	return preload("res://Entities/Characters/Items/WeaponItems/BonusDamage.png")
