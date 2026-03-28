@tool
extends Node2D
class_name HealthBarAndNameDisplay


@onready var name_display: Label = $VBoxContainer/NameDisplay
@onready var health_bar: ProgressBar = $VBoxContainer/HealthBar

const enemy_health_color: Color = Color(1.0, 0.0, 0.0, 1.0)
const ally_health_color: Color = Color(0.0, 1.0, 0.0, 1.0)

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


func set_health(curr_health: float, max_health: float) -> void:
	health_bar.max_value = max_health
	health_bar.value = curr_health
