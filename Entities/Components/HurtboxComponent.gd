extends Area2D
class_name HurtboxComponent

signal got_hit(attack: Attack)

var is_enabled: bool = true

func you_got_entered(attack: Attack) -> void:
	got_hit.emit(attack)
