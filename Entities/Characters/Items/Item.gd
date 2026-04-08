@abstract
extends Resource
class_name Item

# determines in what order this item affects stuff. unique is always first, then flat, then percent; within these categories priority matters.
@abstract
func get_item_priority() -> int

@abstract
func get_price() -> int

# anything that is a flat change (e.g. +100 damage)
@abstract
func apply_flat_on_attack(attack: Attack, is_mine: bool) -> Attack

# anything that isn't a flat change
@abstract
func apply_percentage_on_attack(attack: Attack, is_mine: bool) -> Attack

# anything that is "funky", e.g. changing damage type
@abstract
func apply_unique_on_attack(attack: Attack, is_mine: bool) -> Attack

@abstract
func apply_flat_on_character_stats(character_stats: CharacterStats, is_mine: bool) -> CharacterStats

@abstract
func apply_percent_on_character_stats(character_stats: CharacterStats, is_mine: bool) -> CharacterStats
