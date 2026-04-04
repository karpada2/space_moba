extends Action
class_name BaseAttackAction


var attack: Attack
var character_stats: CharacterStats
var fake_chosen_attack_amount: bool = false
var frames_passed_on_this_action: int = 0
var attacks_done: int = 0

func get_action_length_frames(include_modifiers: bool = true) -> int:
	return (character_stats.frames_before_attack + character_stats.frames_after_attack) * (get_chosen_attack_amount() if include_modifiers else 1)

func get_chosen_attack_amount() -> int:
	return 1 if fake_chosen_attack_amount else int(chosen_choice)

func set_frames_left(frames_left: int) -> void:
	set_max_attack_amount(1 + int(float(frames_left) / (character_stats.frames_before_attack + character_stats.frames_after_attack)))

func set_max_attack_amount(amount: int) -> void:
	if amount >= 1:
		choices = []
		for i: int in amount:
			choices.append(str(i+1))
		if chosen_choice not in choices:
			chosen_choice = choices[0]
		update_modifiers.emit(self)
	else:
		set_max_attack_amount(1)

static func create(attack_in: Attack, character_stats_in: CharacterStats) -> BaseAttackAction:
	var new_action: BaseAttackAction = BaseAttackAction.new()
	new_action.action_name = "Attack"
	new_action.action_length_turns = 1
	new_action.target_type = TargetingType.ENEMY
	
	new_action.character_stats = character_stats_in
	
	new_action.choices_title = "Times To Attack"
	
	new_action.attack = attack_in
	
	return new_action

func clone() -> BaseAttackAction:
	var new_action: BaseAttackAction = _clone_inner()
	new_action.attack = self.attack.clone()
	
	new_action.character_stats = self.character_stats
	new_action.fake_chosen_attack_amount = self.fake_chosen_attack_amount
	
	return new_action

func _new_inner() -> BaseAttackAction:
	return BaseAttackAction.new()

func run(_frames_passed: int) -> bool:
	if target_entity and target_entity.getting_hit_manager and frames_passed_on_this_action == character_stats.frames_before_attack:
		target_entity.getting_hit_manager.attack(attack)
		attacks_done += 1
	if frames_passed_on_this_action == character_stats.frames_before_attack + character_stats.frames_after_attack:
		frames_passed_on_this_action = 0
	else:
		frames_passed_on_this_action += 1
	return attacks_done < get_chosen_attack_amount() and frames_passed_on_this_action == 0
