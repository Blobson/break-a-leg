class_name TileMapGenerator extends TileMap

const CENTER_TO_EDGE_TILES: int = 7
const FIRST_TILE: Vector2i = Vector2i(10, 53)

@export var max_height: int = 300

var building_layer: int = 0
var windows_layer: int = 1
var non_collision_objects_layer: int = 2
var tiles_id: int = 0
var windows_id: int = 4
var building_parametres = BuildingParametres.new()


func _ready():
	clear()
	tile_map_generator()


func tile_map_generator():
	building_generator()
	window_placed()
	poster_placed()


class BuildingParametres:
	var tile_type : int = randi_range(0, 6)
	var alternative_tile_type: int = alternative_tile_select()
	var alternative_tile_distance: int = alternative_tile_distance_select()
	var window_horizontal_distance: int = randi_range(2, 3)
	var window_tipe_1 = randi_range(0, 2)
	var width = CENTER_TO_EDGE_TILES * 2 + 1
	
	
	#Выбор альтернативного тайла
	func alternative_tile_select():
		var generated_value = randi_range(0, 6)
		while generated_value == tile_type:
			generated_value = randi_range(0, 6)
		return generated_value
		
		
	#Выбор дистанции между альтернативными тайлами (четное значение)
	func alternative_tile_distance_select():
		var generated_value: int = randi_range(5, 11)
		while generated_value % 2 != 0:
			generated_value = randi_range(5, 11)
		return generated_value
	
	
	#Выбор тайла для здания
	func select_tile(x: int, y: int):
		var tile_row = tile_type
		if y % alternative_tile_distance == 0:
			tile_row = alternative_tile_type
		if x == 0:
			return Vector2i(0, tile_row)
		elif x == width-1:
			return Vector2i(3, tile_row)
		return Vector2i(2 if randi_range(0, 19) == 0 else 1, tile_row)
	
	
	#Выбор тайла окна
	func window_tile_select(x: int):
		if x % 3 == 0:
			return Vector2i(1,0)
		else:
			return Vector2i(2 if randi_range(0, 2) == 0 else 0, 0)
	
	
	#Генерация массива симметричных x координат для расположения окон
	func window_x_generator():
		var generated_array = []
		var generated_array_size = randi_range(5, 10)
		var current_divider = randi_range(2, 3)
		generated_array.resize(generated_array_size)
		var mirror_counter = 0;
		for i in range(generated_array_size):
			if i < (generated_array_size / 2):
				generated_array[i] = randi_range(1,7)
				while generated_array[i] % current_divider == 0:
					generated_array[i] = randi_range(1,7)
			else:
				generated_array[i] = 14 - generated_array[mirror_counter]
				mirror_counter += 1	
		var generated_array_unique = []
		for x in generated_array:
			if !generated_array_unique.has(x):
				generated_array_unique.push_back(x)
		return generated_array_unique
		
		
	#Выбор постера
	func poster_select():
		var x = randi_range(0, 2)
		return Vector2i(x, 0)	


#Генерация здания 
func building_generator():	
	for y in range(0, max_height):
		for x in range(0, building_parametres.width):
			var tile: Vector2i = building_parametres.select_tile(x, y)
			set_cell(building_layer, Vector2i(x - CENTER_TO_EDGE_TILES, -y), tiles_id, tile, 0)


#Расположение окон
func window_placed():
	var window_x = [];
	window_x = building_parametres.window_x_generator()
	for y in range(4, max_height):
		if y % 2 != 0:
			continue
		elif y % building_parametres.alternative_tile_distance == 0:
			window_x = building_parametres.window_x_generator()
		else:
			for x in window_x:
				var tile = building_parametres.window_tile_select(x)
				set_cell(windows_layer, Vector2i(x - CENTER_TO_EDGE_TILES, -y), windows_id, tile, 0)


#Расположение постеров
func poster_placed():
	for y in range(4, max_height):
		if y % building_parametres.alternative_tile_distance == 0:
			var x = randf_range(1, building_parametres.width-1)
			var poster_atlas = randi_range(1,3)
			set_cell(non_collision_objects_layer, Vector2i(x - CENTER_TO_EDGE_TILES, -y), poster_atlas, building_parametres.poster_select(), 0)
	
