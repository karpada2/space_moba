@abstract
extends EntityBase
class_name CharacterBase

var detection_area: DetectionAreaComponent

var start_pos: Vector2

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
