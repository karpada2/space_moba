@tool
extends PanelContainer
class_name TopBarCharacterShowcase


@onready var character_portrait: TextureRect = $VBoxContainer/CharacterPortrait
@onready var respawn_timer: Label = $VBoxContainer/CharacterPortrait/RespawnTimer
@onready var health_bar_and_name_display: HealthBarAndNameDisplay = $VBoxContainer/HealthBarAndNameDisplay
@onready var total_money_showcase: Label = $VBoxContainer/TotalMoneyShowcase

@export var character: CharacterBase:
	set(value):
		if value:
			if character_portrait:
				character_portrait.texture = value.get_portrait()
			if respawn_timer:
				if character:
					if character.respawn_countdown_changed.is_connected(update_respawn_timer):
						character.respawn_countdown_changed.disconnect(update_respawn_timer)
				value.respawn_countdown_changed.connect(update_respawn_timer)
				update_respawn_timer(value.respawn_countdown)
			if health_bar_and_name_display:
				health_bar_and_name_display.health_component = value.health_component
				health_bar_and_name_display.display_name = value.get_display_name()
				health_bar_and_name_display.associated_team = value.my_team
			if total_money_showcase:
				if character and character.money_handler_component:
					if character.money_handler_component.money_changed.is_connected(money_handler_update):
						character.money_handler_component.money_changed.disconnect(money_handler_update)
				value.money_handler_component.money_changed.connect(money_handler_update)
				update_total_money(value.money_handler_component.get_total_money())
		
		character = value


func _ready() -> void:
	character = character

func update_respawn_timer(time_left: int) -> void:
	if respawn_timer:
		respawn_timer.text = str(time_left)
		respawn_timer.visible = time_left > 0

func money_handler_update(total_money: float, _secured: float, _unsecured: float) -> void:
	update_total_money(total_money)

func update_total_money(total_money: float) -> void:
	if total_money_showcase:
		total_money_showcase.text = str(int(total_money)) + " ₪"
