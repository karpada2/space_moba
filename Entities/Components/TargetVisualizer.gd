extends CanvasLayer
class_name TargetVisualizer

@onready var line_visualizer: Line2D = $LineVisualizer
@onready var position_visualizer: Sprite2D = $PositionVisualizer
@onready var entity_visualizer: Sprite2D = $EntityVisualizer

var target_entity: Node2D = null

const invalid_mix_value: float = 0.7

@export_category("Enable / Disable")
@export var line_visualization_enabled: bool = false:
	set(value):
		if line_visualizer:
			line_visualizer.visible = value
		line_visualization_enabled = value
@export var position_visualization_enabled: bool = false:
	set(value):
		if position_visualizer:
			position_visualizer.visible = value
		position_visualization_enabled = value
@export var entity_visualization_enabled: bool = false:
	set(value):
		if entity_visualizer:
			entity_visualizer.visible = value
		entity_visualization_enabled = value
@export var is_valid: bool = true:
	set(value):
		if value:
			if line_visualizer:
				line_visualizer.material.set("shader_parameter/mix_amount", 0.0)
			if position_visualizer:
				position_visualizer.material.set("shader_parameter/mix_amount", 0.0)
			if entity_visualizer:
				entity_visualizer.material.set("shader_parameter/mix_amount", 0.0)
		else:
			if line_visualizer:
				line_visualizer.material.set("shader_parameter/mix_amount", invalid_mix_value)
			if position_visualizer:
				position_visualizer.material.set("shader_parameter/mix_amount", invalid_mix_value)
			if entity_visualizer:
				entity_visualizer.material.set("shader_parameter/mix_amount", invalid_mix_value)

@export_category("Assets")
@export var line_color: Color:
	set(value):
		if line_visualizer:
			line_visualizer.default_color = value
		line_color = value
@export var line_points: PackedVector2Array:
	set(value):
		set_line_points(value)
@export var position_visualization_image: Texture2D:
	set(value):
		if position_visualizer:
			position_visualizer.texture = value
		position_visualization_image = value
@export var entity_visualization_image: Texture2D:
	set(value):
		if entity_visualizer:
			entity_visualizer.texture = value
		entity_visualization_image = value

func _ready() -> void:
	if line_visualizer:
		if is_valid:
			line_visualizer.material.set("shader_parameter/mix_amount", 0.0)
		else:
			line_visualizer.material.set("shader_parameter/mix_amount", invalid_mix_value)
		line_visualizer.visible = line_visualization_enabled
	if position_visualizer:
		if is_valid:
			position_visualizer.material.set("shader_parameter/mix_amount", 0.0)
		else:
			position_visualizer.material.set("shader_parameter/mix_amount", invalid_mix_value)
		position_visualizer.texture = position_visualization_image
		position_visualizer.visible = position_visualization_enabled
	if entity_visualizer:
		if is_valid:
			entity_visualizer.material.set("shader_parameter/mix_amount", 0.0)
		else:
			entity_visualizer.material.set("shader_parameter/mix_amount", invalid_mix_value)
		entity_visualizer.texture = entity_visualization_image
		entity_visualizer.visible = entity_visualization_enabled

func _physics_process(_delta: float) -> void:
	if target_entity:
		entity_visualizer.global_position = target_entity.global_position

func choose_enabled(line_enabled: bool = false, position_enabled: bool = false, entity_enabled: bool = false) -> void:
	line_visualization_enabled = line_enabled
	position_visualization_enabled = position_enabled
	entity_visualization_enabled = entity_enabled

# receives points in global space
func set_line_points(points: PackedVector2Array) -> void:
	line_visualizer.points = points

func set_target_position(target_position: Vector2) -> void:
	position_visualizer.global_position = target_position

func set_target_entity(entity: Node2D) -> void:
	target_entity = entity
