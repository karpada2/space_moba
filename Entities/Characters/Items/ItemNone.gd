extends Item
class_name ItemNone

const ITEM_NAME: String = "None"

func get_item_tier() -> ItemTier:
	return ItemTier.BASIC

func get_attacked_stat_affecter(_attack: Attack, _attack_result_info: AttackResultInfo) -> StatAffecter:
	return DummyStatAffecter.new()

func get_attacking_stat_affecter(_attack: Attack, _attack_result_info: AttackResultInfo) -> StatAffecter:
	return DummyStatAffecter.new()

func get_normal_stat_affecter() -> StatAffecter:
	return DummyStatAffecter.new()

func clone() -> Item:
	return self


func get_item_icon() -> Texture2D:
	return preload("res://Entities/Characters/Items/ItemNone.png")
