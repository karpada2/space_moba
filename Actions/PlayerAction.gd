extends Resource
class_name PlayerAction


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
var target_position: Vector2
## holds the target entity, if targetType is *NOT* POSITION.[br]
## should only be read.
var target_entity: EntityBase

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



static func create(
			action_name_in: String, 
			action_length_turns_in: int, 
			target_type_in: TargetingType, 
			switches_in: Dictionary[String, bool],
			choices_in: Array[String], 
			choices_title_in: String, 
		) -> PlayerAction:
	
	var newAction: PlayerAction = PlayerAction.new()
	newAction.action_name = action_name_in
	newAction.action_length_turns = action_length_turns_in
	newAction.target_type = target_type_in
	newAction.choices = choices_in.duplicate(true)
	newAction.choices_title = choices_title_in
	newAction.switches = switches_in.duplicate(true)
	newAction.chosen_choice = "" if newAction.choices.is_empty() else newAction.choices[0]
	
	return newAction

func clone() -> PlayerAction:
	var newAction: PlayerAction = PlayerAction.create(
			self.action_name, 
			self.action_length_turns, 
			self.target_type, 
			self.switches, 
			self.choices, 
			self.choices_title, 
		)
	
	newAction.target_position = Vector2(self.target_position.x, self.target_position.y)
	newAction.target_entity = self.target_entity
	newAction.chosen_choice = self.chosen_choice
	
	return newAction
