extends WeaponItem
class_name ItemBonusDamage

const ITEM_NAME: String = "'Roided Up Arms"

func get_item_priority() -> int:
	return 2

func get_item_tier() -> ItemTier:
	return ItemTier.BASIC

func apply_on_attack(attack: Attack, is_mine: bool) -> Attack:
	if is_mine:
		var condition: Callable = func(attack_in: Attack) -> bool:
			if attack_in is BasicAttack:
				if attack_in._damage_type == Enums.DamageType.PHYSICAL:
					return true
			return false
		attack.apply_number_modifier(ModifiedNumber.create(0, 10), condition)
	return attack

func apply_on_character_stats(character_stats: CharacterStats, _is_mine: bool) -> CharacterStats:
	return character_stats
