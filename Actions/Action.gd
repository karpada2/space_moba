@abstract
extends Resource
## Actions for entities to run
class_name Action


enum TargetingType {
	## no targeting, used for things like auto-self cast abilities
	NONE,
	## choose an ally to apply to, such as healing abilities
	ALLY,
	## choose an enemy to apply to, such as damaging actions
	ENEMY,
	## choose any entity to apply to
	ANY,
	## choose a position, such as movement
	POSITION
}



## name of the action. used for identifying.[br]
## should be written to and read from.
var action_name: String


## how long the action takes.[br]
## should be written to and read from.
var action_length_turns: int


## holds the targeting type for this action.[br]
## should only be written to.
var target_type: TargetingType

## holds the target position, if and only if targetType is POSITION.[br]
## should only be read.
var target_position: Vector2:
	set = _set_target_position
## holds the target entity, if targetType is *NOT* POSITION.[br]
## should only be read.
var target_entity: EntityBase:
	set = _set_target_entity

## Whether a target entity or position has been chosen
var target_chosen: bool = false

## options for the radio buttons, if empty none are displayed.[br]
##  Strings and starting values should be written into here, and this should be read from when action is chosen.
var choices: Array[String]
## title for all the radio buttons.[br]
## Should be written to, not read.
var choices_title: String

var chosen_choice: String

## holds the names and values of the switches (multiple toggle-able options), if empty none are displayed.[br]
## Strings and starting values should be written into here, and this should be read from when action is chosen.
var switches: Dictionary[String, bool]

var finished: bool = false


## Currently just checks if a target entity/position has been selected
func is_configured() -> bool:
	return target_chosen

func _set_target_position(new_position: Vector2) -> void:
	if target_type == TargetingType.POSITION:
		target_position = new_position

func _set_target_entity(new_entity: EntityBase) -> void:
	if target_type in [TargetingType.ALLY, TargetingType.ENEMY, TargetingType.ANY]:
		target_entity = new_entity

func set_target_position(new_position: Vector2, simulate: bool = false) -> void:
	if target_type == TargetingType.POSITION:
		target_position = new_position
		if not simulate and target_position.is_finite():
			target_chosen = true
			target_set()

func set_target_entity(new_entity: EntityBase, simulate: bool = false) -> void:
	if target_type in [TargetingType.ALLY, TargetingType.ENEMY, TargetingType.ANY]:
		target_entity = new_entity
		if not simulate and target_entity:
			target_chosen = true
			target_set()

func reset_target() -> void:
	target_chosen = false

func target_set() -> void:
	pass

@abstract
func get_action_length_frames() -> int

@abstract
func clone() -> Action

@abstract
func _new_inner() -> Action


func _clone_inner() -> Action:
	var new_action: Action = self._new_inner()
	
	new_action.action_name = self.action_name
	new_action.action_length_turns = self.action_length_turns
	new_action.target_type = self.target_type
	new_action.choices = self.choices.duplicate(true)
	new_action.choices_title = self.choices_title
	new_action.switches = self.switches.duplicate(true)
	new_action.chosen_choice = self.chosen_choice
	
	if self.is_configured():
		new_action.target_position = Vector2(self.target_position.x, self.target_position.y)
		new_action.target_entity = self.target_entity
	new_action.chosen_choice = self.chosen_choice
	
	return new_action

## works like in RoadRunner, returns whether the action should run again
@abstract
func run(frames_passed: int) -> bool
