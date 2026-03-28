@tool
extends ProgressBar

@export var line_color: Color = Color(0, 0, 0, 0.7)
@export var line_width: float = 1.0
@export var segment_divisor: float = 100.0

func _draw() -> void:
	var segment_count: int = int(max_value / segment_divisor)
	if segment_count < 2:
		return
	
	for i: int in range(1, segment_count):
		var x: float = (size.x / segment_count) * i
		draw_line(Vector2(x, 0), Vector2(x, size.y), line_color, line_width)

func _process(_delta: float) -> void:
	queue_redraw()
