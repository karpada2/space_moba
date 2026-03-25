extends Node
class_name TargetChooser


@onready var entity_detector: Area2D = $EntityDetector

@export var my_team: Enums.Team = Enums.Team.GOOD

var enabled: bool = false

var overlapping_entities: Array[EntityBase] = []


func _on_entity_detector_body_entered(body: Node2D) -> void:
	if body is EntityBase:
		overlapping_entities.append(body)

func _on_entity_detector_body_exited(body: Node2D) -> void:
	if body is EntityBase:
		overlapping_entities.erase(body)

func _physics_process(_delta: float) -> void:
	if enabled:
		entity_detector.global_position = _get_global_mouse_position()


func _get_global_mouse_position() -> Vector2:
	return GameRoot.get_game_root().get_global_mouse_position()

func is_left_mouse_button_just_pressed() -> bool:
	return Input.is_action_just_pressed("mouse_press")

func is_right_mouse_button_just_pressed() -> bool:
	return Input.is_action_just_pressed("mouse_off_press")

func get_mouse_target_position() -> Vector2:
	if enabled:
		return _get_global_mouse_position()
	else:
		return Vector2.INF

func get_enemy_target() -> EntityBase:
	if enabled:
		var closest_entity: EntityBase = null
		for entity: EntityBase in overlapping_entities:
			if ((entity.my_team == Enums.Team.EVIL and my_team == Enums.Team.GOOD) or (entity.my_team == Enums.Team.GOOD and my_team == Enums.Team.EVIL) or (entity.my_team == Enums.Team.NONE)) and entity.visible:
				if closest_entity == null or closest_entity.global_position.distance_squared_to(_get_global_mouse_position()) > entity.global_position.distance_squared_to(_get_global_mouse_position()):
					closest_entity = entity
		return closest_entity
	else:
		return null

func get_ally_target() -> EntityBase:
	if enabled:
		var closest_entity: EntityBase = null
		for entity: EntityBase in overlapping_entities:
			if (entity.my_team == my_team) and entity.visible:
				if closest_entity == null or closest_entity.global_position.distance_squared_to(_get_global_mouse_position()) > entity.global_position.distance_squared_to(_get_global_mouse_position()):
					closest_entity = entity
		return closest_entity
	else:
		return null

func get_any_target() -> EntityBase:
	if enabled:
		var closest_entity: EntityBase = null
		for entity: EntityBase in overlapping_entities:
			if entity.visible:
				if closest_entity == null or closest_entity.global_position.distance_squared_to(_get_global_mouse_position()) > entity.global_position.distance_squared_to(_get_global_mouse_position()):
					closest_entity = entity
		return closest_entity
	else:
		return null
