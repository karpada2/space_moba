extends MarginContainer
class_name InMatchStatsShowcase


var top_bar_character_showcase_scene: PackedScene = preload("res://HUD/EntityStuff/Teams/TopBarCharacterShowcase.tscn")


@onready var game_length_showcase: Label = $CenterContainer/HBoxContainer/GameLengthShowcase/GameLengthShowcase
@onready var evil_team_characters: HBoxContainer = $CenterContainer/HBoxContainer/EvilTeamCharacters
@onready var good_team_characters: HBoxContainer = $CenterContainer/HBoxContainer/GoodTeamCharacters

func update_characters(good_characters: Array[CharacterBase], evil_characters: Array[CharacterBase]) -> void:
	for child: Node in evil_team_characters.get_children():
		child.queue_free()
	for child: Node in good_team_characters.get_children():
		child.queue_free()
	
	for character: CharacterBase in evil_characters:
		var character_showcase: TopBarCharacterShowcase = top_bar_character_showcase_scene.instantiate()
		character_showcase.character = character
		
		evil_team_characters.add_child(character_showcase)
	for character: CharacterBase in good_characters:
		var character_showcase: TopBarCharacterShowcase = top_bar_character_showcase_scene.instantiate()
		character_showcase.character = character
		
		good_team_characters.add_child(character_showcase)
	
