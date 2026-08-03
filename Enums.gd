extends Node

enum DamageType {
	TRUE,
	PHYSICAL,
	MAGICAL
}

enum Team {
	NONE,
	GOOD,
	EVIL,
	NULL
}

func is_opposing_teams(a: Team, b: Team) -> bool:
	if a == b:
		return false
		
	if a == Team.NULL or b == Team.NULL:
		return false
	
	if a == Team.NONE or b == Team.NONE:
		return true
	
	if (a == Team.GOOD and b == Team.EVIL) or (a == Team.EVIL and b == Team.GOOD):
		return true
	
	return false

func is_friendly_teams(a: Team, b: Team) -> bool:
	if a == Team.NULL or b == Team.NULL:
		return false
	
	if a == Team.NONE or b == Team.NONE:
		return false
	
	if a == b:
		return true
	
	return false

enum EntityStats {
	MOVE_SPEED,
	MAGICAL_RESIST,
	PHYSICAL_RESIST,
	BASIC_ATTACK_STARTUP_FRAMES,
	BASIC_ATTACK_ENDLAG_FRAMES,
	BASIC_ATTACK_DAMAGE,
	MAX_HEALTH,
	MAGICAL_PROWESS,
}
