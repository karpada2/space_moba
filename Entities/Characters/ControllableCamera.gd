extends Camera2D
class_name ControllableCamera

@export var base_zoom: float = 0.25
@export var max_distance_from_interest: float = 500
@export var pan_speed: float = 500.0
@export var zoom_step: float = 0.05
@export var zoom_min: float = 0.1
@export var zoom_max: float = 2.5

var _manual_mode: bool = false

func _ready() -> void:
	TurnChoosingManager.choosing_start.connect(_on_auto_camera)

func _on_auto_camera(team: Enums.Team) -> void:
	_manual_mode = false
	center_camera_on_interest(team)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_manual_mode = true
			zoom += Vector2(zoom_step, zoom_step)
			if zoom.x > zoom_max:
				zoom = Vector2(zoom_max, zoom_max)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_manual_mode = true
			zoom -= Vector2(zoom_step, zoom_step)
			if zoom.x < zoom_min:
				zoom = Vector2(zoom_min, zoom_min)

func _process(delta: float) -> void:
	var direction: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("camera_up"):
		direction.y -= 1
	if Input.is_action_pressed("camera_down"):
		direction.y += 1
	if Input.is_action_pressed("camera_left"):
		direction.x -= 1
	if Input.is_action_pressed("camera_right"):
		direction.x += 1

	if direction != Vector2.ZERO:
		_manual_mode = true
		global_position += direction * pan_speed * (1.0 / zoom.x) * delta

# receives a vector that "bounds" the camera - how far (in absolute value) is the farthest needed object in the x and y directions
func size_vector_to_zoom(size_vector: Vector2) -> float:
	if size_vector == Vector2.ZERO or not size_vector.is_finite():
		return base_zoom
	size_vector *= 2
	var viewport_size: Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), ProjectSettings.get_setting("display/window/size/viewport_height"))
	if (size_vector.x / size_vector.y) > (viewport_size.x / viewport_size.y):
		return (viewport_size.x / size_vector.x) * 0.85
	else:
		return (viewport_size.y / size_vector.y) * 0.85

func center_camera_on_interest(team: Enums.Team) -> void:
	var average_vector: Vector2 = Vector2.ZERO
	var size_vector: Vector2 = Vector2.ZERO
	var valid_flag: bool = true
	var alive_characters: Array[CharacterBase] = GameRoot.get_game_root().get_characters_in_team(team).filter(func(c: CharacterBase) -> bool: return c.is_alive())
	if alive_characters.size() > 1:
		for character: CharacterBase in alive_characters:
			average_vector += (character.global_position / alive_characters.size())
		for character: CharacterBase in alive_characters:
			if average_vector.distance_to(character.global_position) > max_distance_from_interest:
				valid_flag = false

		if not valid_flag:
			average_vector = alive_characters[0].global_position
		else:
			for character: CharacterBase in alive_characters:
				var position_diff: Vector2 = (character.global_position - average_vector).abs() + Vector2(160, 160)
				if position_diff.x > size_vector.x:
					size_vector.x = position_diff.x
				if position_diff.y > size_vector.y:
					size_vector.y = position_diff.y
	self.global_position = average_vector
	self.zoom = Vector2(size_vector_to_zoom(size_vector), size_vector_to_zoom(size_vector))
