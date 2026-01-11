
extends PointLight2D
class_name DetectionAreaComponent

@export var diameter: int = 256
@export var my_team: Enums.Team = Enums.Team.GOOD:
	set(value):
		if value == Enums.Team.EVIL:
			vision_cone_area.set_collision_mask_value(4, false)
			vision_cone_area.set_collision_mask_value(3, true)
		if value == Enums.Team.GOOD:
			vision_cone_area.set_collision_mask_value(4, true)
			vision_cone_area.set_collision_mask_value(3, false)
		my_team = value

@onready var vision_cone_area: Area2D = $VisionCone2D/VisionConeArea
@onready var vision_cone_2d: VisionCone2D = $VisionCone2D

var working: bool = true

func _process(_delta: float) -> void:
	vision_cone_2d.max_distance = (diameter/2.0)
	texture_scale = diameter/256.0
	vision_cone_2d.recalculate_vision()

func enable() -> void:
	working = true
	self.enabled = true
	vision_cone_area.monitoring = true
	vision_cone_2d.recalculate_vision(true)

func disable() -> void:
	working = false
	self.enabled = false
	vision_cone_area.monitoring = false

func get_visible_enemies() -> Array[CharacterBase]:
	var visible_enemies: Array[CharacterBase] = []
	if working:
		vision_cone_2d.recalculate_vision(true)
		for node: Node2D in vision_cone_area.get_overlapping_bodies():
			if node is CharacterBase:
				if (node.my_team == Enums.Team.EVIL and my_team == Enums.Team.GOOD) or (node.my_team == Enums.Team.GOOD and my_team == Enums.Team.EVIL):
					visible_enemies.append(node)
	return visible_enemies
