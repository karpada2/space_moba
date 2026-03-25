extends Resource
class_name TurnPhase

# helper class, instantiate this and discard
class OrderTurnPhase:
	static func order(ordered: Array[TurnPhase]) -> OrderTurnPhase:
		for i: int in ordered.size()-1:
			ordered[i]._set_next(ordered[i+1])
		return null

static var GOOD_TEAM_CHOOSE: TurnPhase = TurnPhase._create(0, Enums.Team.GOOD)
static var EVIL_TEAM_CHOOSE: TurnPhase = TurnPhase._create(1, Enums.Team.EVIL)
static var GOOD_TEAM_RESOLVE: TurnPhase = TurnPhase._create(2, Enums.Team.GOOD)
static var EVIL_TEAM_RESOLVE: TurnPhase = TurnPhase._create(3, Enums.Team.EVIL)

@warning_ignore("unused_private_class_variable")
static var _trash: OrderTurnPhase = OrderTurnPhase.order([
	GOOD_TEAM_CHOOSE, 
	GOOD_TEAM_RESOLVE, 
	EVIL_TEAM_CHOOSE, 
	EVIL_TEAM_RESOLVE,
	GOOD_TEAM_CHOOSE
	])

var _value: int
var _associated_team: Enums.Team
var _next_phase: TurnPhase

static func _create(value: int, associated_team: Enums.Team) -> TurnPhase:
	value = value % 4
	var temp: TurnPhase = TurnPhase.new()
	temp._value = value
	temp._associated_team = associated_team
	
	return temp

func _set_next(turn_phase: TurnPhase) -> TurnPhase:
	var temp: TurnPhase = self.get_next()
	self._next_phase = turn_phase
	
	return temp

func get_next() -> TurnPhase:
	return _next_phase

func get_team() -> Enums.Team:
	return self._associated_team

func is_choose_phase() -> bool:
	return self._value in [0, 1]
