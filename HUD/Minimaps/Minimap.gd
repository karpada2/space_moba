extends TextureRect
class_name Minimap

@export var full_map_binding_box: Vector2 = Vector2(2496, 2496)
@export var mini_map_binding_box: Vector2 = Vector2(256, 256)

@export var my_team: Enums.Team = Enums.Team.GOOD

var characters_with_relevant_icons: Dictionary[CharacterBase, TextureRect]

func _ready() -> void:
	TurnResolutionManager.resolution_advance.connect(advance)
	TurnResolutionManager.resolution_started.connect(update_character_icons_wrapper)

func _process(_delta: float) -> void:
	self.size = mini_map_binding_box

func update_character_icons_wrapper(_team: Enums.Team) -> void:
	update_character_icons()

func update_character_icons() -> void:
	if not characters_with_relevant_icons.is_empty():
		for node: Node in characters_with_relevant_icons.values():
			node.queue_free()
		characters_with_relevant_icons.clear()
	
	for character: CharacterBase in GameRoot.get_game_root().get_all_characters():
		var texture_rect: TextureRect = TextureRect.new()
		texture_rect.texture = preload("res://HUD/Minimaps/Icons/EarthIcon.png")
		texture_rect.visible = false
		characters_with_relevant_icons.set(character, texture_rect)
		add_child.call_deferred(texture_rect)

func advance(resolving_team: Enums.Team, _delta: float) -> void:
	update_map(resolving_team)

func update_map(resolving_team: Enums.Team) -> void:
	var visible_characters: Array[CharacterBase] = GameRoot.get_game_root().get_all_visible_characters(resolving_team)
	for character: CharacterBase in characters_with_relevant_icons.keys():
		if character in visible_characters:
			var new_pos: Vector2 = (character.global_position + (full_map_binding_box/2))*(mini_map_binding_box/full_map_binding_box)
			characters_with_relevant_icons.get(character).visible = true
			characters_with_relevant_icons.get(character).position = new_pos
		else:
			characters_with_relevant_icons.get(character).visible = false
