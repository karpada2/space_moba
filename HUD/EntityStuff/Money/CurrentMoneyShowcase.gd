@tool
extends VBoxContainer
class_name CurrentMoneyShowcase


@onready var secured_money_label: Label = $SecuredMoney
@onready var unsecured_money_label: Label = $UnsecuredMoney


var last_updated_secured_money: float = 0
var last_updated_unsecured_money: float = 0


@export var money_handler: MoneyHandlerComponent:
	set(value):
		if money_handler:
			money_handler.money_changed.disconnect(update_money)
		money_handler = value
		last_updated_secured_money = money_handler.get_secured_money()
		last_updated_unsecured_money = money_handler.get_unsecured_money()
		update_display(last_updated_secured_money, last_updated_unsecured_money)
		money_handler.money_changed.connect(update_money)


func _ready() -> void:
	update_display(last_updated_secured_money, last_updated_unsecured_money)


func update_money(_total: float, secured_money: float, unsecured_money: float) -> void:
	last_updated_secured_money = secured_money
	last_updated_unsecured_money = unsecured_money
	update_display(secured_money, unsecured_money)

func update_display(secured_money: float, unsecured_money: float) -> void:
	if secured_money_label:
		secured_money_label.text = str(int(secured_money)) + " ₪"
	if unsecured_money_label:
		unsecured_money_label.text = str(int(unsecured_money)) + " ₪ Unsecured"
		unsecured_money_label.visible = unsecured_money > 0
