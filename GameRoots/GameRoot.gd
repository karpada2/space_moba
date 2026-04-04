@abstract
extends Node2D
class_name GameRoot

signal any_button_pressed()

class CharacterArray extends Resource:
	var array: Array[CharacterBase]

static var _current_game_root: GameRoot
var current_turn_phase: TurnPhase
var last_turn_phase: TurnPhase

var game_length: int = 0

func _ready() -> void:
	self._current_game_root = self

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton or event is InputEventKey:
		any_button_pressed.emit()

# returns what offset each rect should get
func resolve_rect_overlaps(rects: Array[Rect2], max_iterations: int = 100) -> Array[Vector2]:
	var result: Array[Rect2] = rects.duplicate()
	
	for _iter: int in range(max_iterations):
		var any_overlap: bool = false
		
		for i: int in range(result.size()):
			for j: int in range(i + 1, result.size()):
				var a: Rect2 = result[i]
				var b: Rect2 = result[j]
				var intersection: Rect2 = a.intersection(b)
				
				if intersection.has_area():
					any_overlap = true
					
					# Find the smallest axis to push along
					var push_x: float = intersection.size.x
					var push_y: float = intersection.size.y
					
					var half: Vector2 = Vector2.ZERO
					if push_x < push_y:
						# Push horizontally
						half.x = push_x / 2.0 + 0.5
						if a.get_center().x > b.get_center().x:
							result[i] = Rect2(a.position + Vector2(half.x, 0), a.size)
							result[j] = Rect2(b.position - Vector2(half.x, 0), b.size)
						else:
							result[i] = Rect2(a.position - Vector2(half.x, 0), a.size)
							result[j] = Rect2(b.position + Vector2(half.x, 0), b.size)
					else:
						# Push vertically
						half.y = push_y / 2.0 + 0.5
						if a.get_center().y > b.get_center().y:
							result[i] = Rect2(a.position + Vector2(0, half.y), a.size)
							result[j] = Rect2(b.position - Vector2(0, half.y), b.size)
						else:
							result[i] = Rect2(a.position - Vector2(0, half.y), a.size)
							result[j] = Rect2(b.position + Vector2(0, half.y), b.size)
		
		if not any_overlap:
			break  # Converged early
	
	
	
	var offset_result: Array[Vector2] = []
	offset_result.resize(result.size())
	
	for i: int in range(result.size()):
		offset_result[i] = result[i].get_center() - rects[i].get_center()
	
	return offset_result

func _physics_process(_delta: float) -> void:
	var healthbars: Array[OffsetHealthBarAndNameDisplay] = []
	var rects: Array[Rect2] = []
	for node: Node in get_tree().get_nodes_in_group("OnEntitiesHealthbars"):
		if node is OffsetHealthBarAndNameDisplay and node.visible:
			healthbars.append(node)
			rects.append(node.get_global_rect(true))
	
	var offsets: Array[Vector2] = resolve_rect_overlaps(rects)
	for i: int in range(healthbars.size()):
		healthbars[i].temporary_offset = healthbars[i].temporary_offset.lerp(offsets[i], 0.2)

static func get_game_root() -> GameRoot:
	return _current_game_root


@abstract 
func get_entities_in_team(team: Enums.Team, alive_only: bool = true) -> Array[EntityBase]

## returns all characters that are visible to the requested team
@abstract
func get_all_visible_characters(team: Enums.Team, alive_only: bool = true) -> Array[CharacterBase]

@abstract
func get_all_visible_entities(team: Enums.Team, alive_only: bool = true) -> Array[EntityBase]

@abstract 
func get_camera() -> ControllableCamera

@abstract
func get_all_entities(alive_only: bool = true) -> Array[EntityBase]

@abstract
func get_enemy_base_position(team: Enums.Team) -> Vector2

@abstract
func entity_died(entity: EntityBase) -> void

func reveal_as_needed(team: Enums.Team) -> void:
	var all_entities: Array[EntityBase] = get_all_entities()
	
	var visible_entities: Array[EntityBase] = get_all_visible_entities(team)
	
	for entity: EntityBase in all_entities:
		if entity in visible_entities:
			entity.reveal()
		else:
			entity.unreveal()

func enable_team(team: Enums.Team) -> void:
	var team_entities: Array[EntityBase] = get_entities_in_team(team)
	for entity: EntityBase in team_entities:
		entity.enable()

func disable_team(team: Enums.Team) -> void:
	var team_entities: Array[EntityBase] = get_entities_in_team(team)
	for entity: EntityBase in team_entities:
		entity.disable()

func update_healthbars_enemy_status(team: Enums.Team) -> void:
	for node: Node in get_tree().get_nodes_in_group("AllHealthBars"):
		if node is OffsetHealthBarAndNameDisplay or node is HealthBarAndNameDisplay:
			node.update_as_enemy(team)

@abstract
func switch_character_choosing_actions(character: CharacterBase) -> void

@abstract
func get_all_characters(force_update: bool = false, alive_only: bool = true) -> Array[CharacterBase]

@abstract
func get_characters_in_team(team: Enums.Team, alive_only: bool = true) -> Array[CharacterBase]
