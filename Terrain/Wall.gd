
extends StaticBody2D
class_name Wall

var collision_polygon: CollisionPolygon2D
@onready var light_occluder_2d: LightOccluder2D = $LightOccluder2D
@onready var area_collision: CollisionPolygon2D = $Area2D/AreaCollision

func _ready() -> void:
	for child: Node in get_children():
		if child is CollisionPolygon2D:
			collision_polygon = child
	assert(collision_polygon != null, "Wall does not have a collision polygon!")
	light_occluder_2d.occluder.polygon = collision_polygon.polygon
	area_collision.polygon = collision_polygon.polygon

func _process(_delta: float) -> void:
	if (Engine.is_editor_hint()):
		collision_polygon = null
		for child: Node in get_children():
			if child is CollisionPolygon2D:
				collision_polygon = child
		if collision_polygon != null:
			light_occluder_2d.occluder.polygon = collision_polygon.polygon
			area_collision.polygon = collision_polygon.polygon
