@abstract
extends EntityBase
class_name CharacterBase

var detection_area: DetectionAreaComponent

var start_pos: Vector2

var next_chosen_action: PlayerAction

func _ready() -> void:
	super()
	for node: Node in self.get_children():
		if node is DetectionAreaComponent:
			detection_area = node
	detection_area.my_team = self.my_team
	hurtbox_component.revealed.connect(reveal)
	start_pos = global_position

func reveal() -> void:
	show()

func unreveal() -> void:
	self.hide()
	detection_area.disable()

func reveal_visible_enemies() -> void:
	self.show()
	detection_area.enable()
	for area: Area2D in detection_area.vision_cone_area.get_overlapping_areas():
		if area is HurtboxComponent:
			area.reveal()

func get_visible_enemies() -> Array[CharacterBase]:
	return detection_area.get_visible_enemies()

## Returns actions sorted by type (base, abilities, items, etc.).[br]
## The actions in the ActionArrays should be duplicated and not the originals.
@abstract
func get_available_actions() -> Dictionary[String, PlayerActionArray]

## Handles storing what action was selected and with what parameters
func action_selected(connected_signal: Signal, chosen_action: PlayerAction) -> void:
	connected_signal.disconnect(action_selected)
	next_chosen_action = chosen_action
	pass #TODO: implement me
