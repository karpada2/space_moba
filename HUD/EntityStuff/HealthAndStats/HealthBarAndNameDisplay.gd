@tool
extends Node2D
class_name HealthBarAndNameDisplay


@onready var name_display: Label = $Offset/VBoxContainer/NameDisplay
@onready var health_bar: ProgressBar = $Offset/VBoxContainer/HealthBar
@onready var v_box_container: VBoxContainer = $Offset/VBoxContainer
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
		if health_bar:
			health_bar.visible = value
		show_health = value
@export var show_name: bool = true:
	set(value):
		if name_display:
			name_display.visible = value
		show_name = value
@export var as_enemy: bool = true:
	set(value):
		if health_bar:
			(health_bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = enemy_health_color if value else ally_health_color
		as_enemy = value
@export var display_name: String:
	set(value):
		if name_display:
			name_display.text = value
		display_name = value
@export var health_component: HealthComponent:
	set(value):
		if health_component:
			if health_component.health_changed.is_connected(set_health):
				health_component.health_changed.disconnect(set_health)
		if value:
			health_component = value
			health_component.health_changed.connect(set_health)
			if health_bar:
				set_health(health_component.curr_health, health_component.max_health)


func _ready() -> void:
	if offset:
		set_offsets()
	if health_bar:
		health_bar.visible = show_health
		(health_bar.get_theme_stylebox("fill") as StyleBoxFlat).bg_color = enemy_health_color if as_enemy else ally_health_color
	if name_display:
		name_display.visible = show_name
		name_display.text= display_name
	if health_component:
		if not health_component.health_changed.is_connected(set_health):
			health_component.health_changed.connect(set_health)
		set_health(health_component.curr_health, health_component.max_health)

func set_offsets(temporary_offset_in: Vector2 = temporary_offset, wanted_offset_in: Vector2 = wanted_offset) -> void:
	offset.position = wanted_offset_in + temporary_offset_in

func get_local_rect(is_remove_temporary_offset: bool = false) -> Rect2:
	var global_rect: Rect2 = get_global_rect(is_remove_temporary_offset)
	return Rect2(to_local(global_rect.position), global_rect.size)

func get_global_rect(is_remove_temporary_offset: bool = false) -> Rect2:
	var result_rect: Rect2 = Rect2(Vector2.ZERO, Vector2.ZERO)
	if visible:
		if show_name and show_health:
			result_rect = v_box_container.get_global_rect()
		if show_name and not show_health:
			result_rect = name_display.get_global_rect()
		if not show_name and show_health:
			result_rect = health_bar.get_global_rect()
	
	if is_remove_temporary_offset:
		return remove_temporary_offset(result_rect)
	return result_rect

func remove_temporary_offset(rect: Rect2) -> Rect2:
	return Rect2(rect.position - temporary_offset, rect.size)


func set_health(curr_health: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = curr_health
