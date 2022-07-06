tool
extends TileMap

export (int) var counter = 0
export (bool) var generate_autotile_collision = true

var tile_size = 16
var sprite_sheet_size = Vector2(12,20)

func _ready() -> void:
	if Engine.editor_hint:
		_generate_autotile_collision()

func _generate_autotile_collision():
	for x in sprite_sheet_size.x:
		for y in sprite_sheet_size.y:
			var shape = ConvexPolygonShape2D.new()
			shape.points = [Vector2(0,0), Vector2(0,tile_size), Vector2(tile_size,tile_size), Vector2(tile_size,0)]
			tile_set.tile_add_shape(0, shape, Transform2D(0.0,Vector2(0,0)), false, Vector2(x,y))

