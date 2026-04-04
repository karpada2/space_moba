extends Node
class_name MoneyHandlerComponent


signal money_changed(total: float, secured: float, unsecured: float)


var _total_money: float
var _secured_money: float
var _unsecured_money: float

@export_range(0, 1, 0.001) var total_money_dropped_on_death: float = 0.05

func get_total_money() -> float:
	return _total_money

func get_secured_money() -> float:
	return _secured_money

func get_unsecured_money() -> float:
	return _unsecured_money


func emit_money_changed(total_money_in: float = _total_money, secured_money_in: float = _secured_money, unsecured_money_in: float = _unsecured_money) -> void:
	money_changed.emit(total_money_in, secured_money_in, unsecured_money_in)


func add_money(amount: float, secured: bool = true) -> void:
	if amount > 0:
		if secured:
			_total_money += amount
			_secured_money += amount
		else:
			_unsecured_money += amount
		emit_money_changed()

func lose_unsecured_money() -> void:
	_unsecured_money = 0
	emit_money_changed()

func secure_money(amount: float, percentage: bool = false, min_amount: float = 1) -> void:
	if amount > 0:
		var amount_to_secure: float
		if percentage:
			amount_to_secure = minf(min_amount, amount*_unsecured_money)
		else:
			amount_to_secure = amount
		
		amount_to_secure = minf(_unsecured_money, amount_to_secure)
		add_money(amount_to_secure)
		_unsecured_money -= amount_to_secure
		emit_money_changed()

func get_money_dropped_on_death() -> float:
	return _unsecured_money + (_total_money * total_money_dropped_on_death)
