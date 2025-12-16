@tool
extends PointLight2D
class_name DetectionAreaComponent

@export var diameter: int = 256
@export_range(1, 2, 1) var my_team: int = 1
@onready var vision_cone_area: Area2D = $VisionCone2D/VisionConeArea
@onready var vision_cone_2d: VisionCone2D = $VisionCone2D

@export var working: bool = true

func _ready() -> void:
	vision_cone_area.set_collision_mask_value(-my_team+5, true)

func _process(_delta: float) -> void:
	vision_cone_2d.max_distance = (diameter/2.0)
	texture_scale = diameter/256.0
	if (Engine.is_editor_hint()):
		vision_cone_2d.recalculate_vision()
