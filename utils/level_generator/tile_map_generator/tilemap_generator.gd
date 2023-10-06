class_name TileMapGenerator extends TileMap

const CENTER_TO_EDGE_TILES: int = 7
const FIRST_TILE: Vector2i = Vector2i(10, 53)

var max_height: int = 150

var layers: Dictionary = {
	"building": 0,
	"windows": 1,
	"non_collision_objects": 2
}

func _ready():
	self.clear()
	tile_map_generator()


func tile_map_generator():
	building_generator()
	window_placed()
	poster_placed()

class BuildingParametres:
	var tile_type : int = randi() % 6 + 1
	var alternative_tile_type: int = alternative_tile_select()
	var alternative_tile_distance: int = randi_range(4, 10)
	var width = CENTER_TO_EDGE_TILES * 2 + 1
	
	
	#выбор альтернативного тайла
	func alternative_tile_select():
		var generated_value = randi() % 6 + 1
		while generated_value == tile_type:
			generated_value = randi() % 6 + 1
		return generated_value
	
	func select_tile(x : int, y : int):
		var tile_row = tile_type
		if y % alternative_tile_distance == 0:
			tile_row = alternative_tile_type
		
		if x == 0:
			return Vector2i(0, tile_row)
		elif x == width-1:
			return Vector2i(3, tile_row)
		
		return Vector2i(2 if randi_range(0,19) == 0 else 1, tile_row)
	
	
func building_generator():
	var building_parametres = BuildingParametres.new()
	for y in range(0, max_height):
		for x in range(0, CENTER_TO_EDGE_TILES * 2 + 2):
			var tile: Vector2i = building_parametres.select_tile(x, y)
			set_cell(layers.building, Vector2i(x - CENTER_TO_EDGE_TILES, -y), 0, tile, 0)



func window_placed():
	pass
	
func poster_placed():
	pass
	
