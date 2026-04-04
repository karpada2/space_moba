extends Resource
class_name CharacterStats

var frames_before_attack: int
var frames_after_attack: int

var move_speed: float

static func create(frames_before_attack_in: int, frames_after_attack_in: int, move_speed_in: float) -> CharacterStats:
	var new_stats: CharacterStats = CharacterStats.new()
	
	new_stats.frames_before_attack = frames_before_attack_in
	new_stats.frames_after_attack = frames_after_attack_in
	new_stats.move_speed = move_speed_in
	
	return new_stats
