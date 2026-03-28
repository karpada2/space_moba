extends TextureRect
class_name Minimap

@export var full_map_binding_box: Vector2 = Vector2(2496, 2496)
@export var mini_map_binding_box: Vector2 = Vector2(256, 256)

@export var my_team: Enums.Team = Enums.Team.NONE

var controllable_camera: ControllableCamera

var camera_view: Panel

var characters_with_relevant_icons: Dictionary[CharacterBase, TextureRect]

func _ready() -> void:
	clip_contents = true
	
	TurnChoosingManager.choosing_start.connect(update_character_icons_wrapper)
	TurnChoosingManager.choosing_advance.connect(advance_wrapper)
	
	TurnResolutionManager.resolution_advance.connect(advance)
	TurnResolutionManager.resolution_started.connect(update_character_icons_wrapper)
	
	camera_view = Panel.new()
	camera_view.add_theme_stylebox_override("panel", preload("res://HUD/Minimaps/CameraViewShower.tres"))
	add_child(camera_view)

func _process(_delta: float) -> void:
	self.size = mini_map_binding_box

func update_character_icons_wrapper(_team: Enums.Team) -> void:
	update_character_icons()

func update_character_icons() -> void:
	if not characters_with_relevant_icons.is_empty():
		for node: Node in characters_with_relevant_icons.values():
			node.queue_free()
		characters_with_relevant_icons.clear()
	
	controllable_camera = GameRoot.get_game_root().get_camera()
	
	for character: CharacterBase in GameRoot.get_game_root().get_all_characters():
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.texture = preload("res://HUD/Minimaps/Icons/EarthIcon.png")
		texture_rect.visible = false
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.size = Vector2(4, 4)
		characters_with_relevant_icons.set(character, texture_rect)
		add_child.call_deferred(texture_rect)

func advance_wrapper(resolving_team: Enums.Team) -> void:
	advance(resolving_team, 0)

func advance(resolving_team: Enums.Team, _frames_since_start: int) -> void:
	if my_team == Enums.Team.NONE or resolving_team == my_team:
		update_map(my_team)

func update_map(resolving_team: Enums.Team) -> void:
	var map_scale: Vector2 = mini_map_binding_box / full_map_binding_box
	var viewport_size: Vector2 = Vector2(
		ProjectSettings.get_setting("display/window/size/viewport_width"),
		ProjectSettings.get_setting("display/window/size/viewport_height")
	)
	var world_view_size: Vector2 = viewport_size / controllable_camera.zoom
	camera_view.size = world_view_size * map_scale
	camera_view.position = (controllable_camera.global_position + (full_map_binding_box / 2)) * map_scale - (camera_view.size / 2)
	
	var visible_characters: Array[CharacterBase] = GameRoot.get_game_root().get_all_visible_characters(resolving_team)
	for character: CharacterBase in characters_with_relevant_icons.keys():
		if character in visible_characters:
			var new_pos: Vector2 = (character.global_position + (full_map_binding_box/2))*(mini_map_binding_box/full_map_binding_box)
			characters_with_relevant_icons.get(character).visible = true
			characters_with_relevant_icons.get(character).position = new_pos - (characters_with_relevant_icons.get(character).size/2)
		else:
			characters_with_relevant_icons.get(character).visible = false
