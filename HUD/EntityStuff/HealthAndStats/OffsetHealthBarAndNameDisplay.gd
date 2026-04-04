@tool
extends Node2D
class_name OffsetHealthBarAndNameDisplay


@onready var health_bar_and_name_display: HealthBarAndNameDisplay = $Offset/HealthBarAndNameDisplay
@onready var offset: Node2D = $Offset


const enemy_health_color: Color = Color(1.0, 0.0, 0.0, 1.0)
const ally_health_color: Color = Color(0.0, 1.0, 0.0, 1.0)

@export var wanted_offset: Vector2 = Vector2(0, 0):
	set(value):
		if offset:
			set_offsets(temporary_offset, value)
		wanted_offset = value
@export var temporary_offset: Vector2 = Vector2(0, 0):
	set(value):
		if offset:
			set_offsets(value, wanted_offset)
		temporary_offset = value
@export var show_health: bool = true:
	set(value):
		if health_bar_and_name_display:
			health_bar_and_name_display.show_health = value
		show_health = value
@export var show_name: bool = true:
	set(value):
		if health_bar_and_name_display:
			health_bar_and_name_display.show_name = value
		show_name = value
@export var as_enemy: bool = true:
	set(value):
		if health_bar_and_name_display:
			health_bar_and_name_display.as_enemy = value
		as_enemy = value
@export var display_name: String:
	set(value):
		if health_bar_and_name_display:
			health_bar_and_name_display.display_name = value
		display_name = value
@export var health_component: HealthComponent:
	set(value):
		if health_bar_and_name_display:
			health_bar_and_name_display.health_component = value
		health_component = value
@export var associated_team: Enums.Team = Enums.Team.NULL
@export var wanted_size: Vector2 = Vector2(320, 64)

func update_as_enemy(current_team: Enums.Team) -> void:
	as_enemy = current_team != associated_team

func _ready() -> void:
	if offset:
		set_offsets()
	if health_bar_and_name_display:
		health_bar_and_name_display.show_health = show_health
		health_bar_and_name_display.show_name = show_name
		health_bar_and_name_display.as_enemy = as_enemy
		health_bar_and_name_display.display_name = display_name
		health_bar_and_name_display.health_component = health_component

func _process(_delta: float) -> void:
	health_bar_and_name_display.size = wanted_size
	health_bar_and_name_display.position = Vector2(-0.5, -1) * health_bar_and_name_display.size

func set_offsets(temporary_offset_in: Vector2 = temporary_offset, wanted_offset_in: Vector2 = wanted_offset) -> void:
	offset.position = wanted_offset_in + temporary_offset_in

func get_local_rect(is_remove_temporary_offset: bool = false) -> Rect2:
	var global_rect: Rect2 = get_global_rect(is_remove_temporary_offset)
	return Rect2(to_local(global_rect.position), global_rect.size)

func get_global_rect(is_remove_temporary_offset: bool = false) -> Rect2:
	var result_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	if visible:
		result_rect = health_bar_and_name_display.get_global_rect_custom()
	
	if is_remove_temporary_offset:
		return remove_temporary_offset(result_rect)
	return result_rect

func remove_temporary_offset(rect: Rect2) -> Rect2:
	return Rect2(rect.position - temporary_offset, rect.size)


func set_health(curr_health: float, max_health: float) -> void:
	health_bar_and_name_display.set_health(curr_health, max_health)
