@abstract
extends Node2D
class_name GameRoot

static var _current_game_root: GameRoot

func _ready() -> void:
	self._current_game_root = self
	get_tree().root.get_viewport().canvas_cull_mask -= 2

static func get_game_root() -> GameRoot:
	return _current_game_root
