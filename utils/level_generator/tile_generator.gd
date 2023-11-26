class_name TileGenerator

const WALL_START_Y = -3
const WINDOW_START_Y = -4
const WINDOW_Y_GAP = 2

var tilemap: TileMap
var level_template: LevelTemplate
var half_width: int
var fly_limits: FlyLimits

var walls_atlas_id: int
var windows_atlas_id: int
var walls_tile_type: int
var frieze_tile_type: int
var frieze_y_step: int
var windows_pattern: Array[Tile]
var windows_pattern_y: int
var windows_change_step: int
var next_client_coords: Vector2i


func init(template: LevelTemplate, map: TileMap):
	level_template = template
	tilemap = map

	@warning_ignore("integer_division")
	half_width = level_template.width / 2
	
	# определяем пределы полёта птиц
	var ts = tilemap.tile_set.tile_size
	fly_limits = FlyLimits.new()
	fly_limits.left = (-half_width - 3) * ts.x
	fly_limits.right = (half_width + 3) * ts.x
	
	# выбираем стеновой тайл
	walls_atlas_id = level_template.random_tile_atlas(LevelTemplate.TileType.WALLS)
	var walls_atlas = tilemap.tile_set.get_source(walls_atlas_id)
	var walls_atlas_size = walls_atlas.get_atlas_grid_size()
	walls_tile_type = randi() % walls_atlas_size.y

	# задаём шаг через который идут Фризы
	frieze_tile_type = wrap(randi() % (walls_atlas_size.y-1) + walls_tile_type + 1, 0, walls_atlas_size.y)
	frieze_y_step = randi_range(5, 6) * WINDOW_Y_GAP

	# выбираем тайлы окон и шаг с которым они размещаются
	windows_atlas_id = level_template.random_tile_atlas(LevelTemplate.TileType.WINDOWS)
	windows_change_step = randi_range(3, 5) * frieze_y_step
	windows_pattern_y = 0
	regenerate_windows_pattern()
	
	next_client_coords = generate_next_client_coords(WINDOW_START_Y)


func generate_next_client_coords(current_floor: int) -> Vector2i:
	return Vector2i(
		generate_next_client_x(),
		current_floor - (level_template.floors_between_clients + randi_range(-1, 1)) * WINDOW_Y_GAP
	)


func generate_next_client_x() -> int:
	var xlist = []
	for x in windows_pattern.size():
		var w = windows_pattern[x]
		if w and w.is_obstacle_allowed:
			xlist.append(x - half_width)
	return Utils.random_choice(xlist)


func regenerate_windows_pattern():
	windows_pattern = [ null ]
	while windows_pattern.size() < level_template.width-1:
		var batch_size = min(randi_range(1, 2), level_template.width - 1 - windows_pattern.size())
		if randi_range(0, 9) == 0:
			batch_size = 3
		var small_windows_in_batch = batch_size - max(1, batch_size - 1)
		while batch_size > 0:
			var tile = Tile.new()
			tile.atlas_id = windows_atlas_id
			if small_windows_in_batch and randi_range(0, batch_size - 1) == 0:
				tile.scene_id = Utils.random_choice(level_template.tiles.windows.small)
				tile.is_obstacle_allowed = false
				small_windows_in_batch -= 1
			else:
				tile.scene_id = Utils.random_choice(level_template.tiles.windows.full)
			windows_pattern.append(tile)
			batch_size -= 1
		windows_pattern.append(null)
	windows_pattern.append(null)
	next_client_coords.x = generate_next_client_x()
	return windows_pattern


func random_scene_tile(tile_type: LevelTemplate.TileType) -> Tile:
	var tile = Tile.new()
	tile.atlas_id = level_template.random_tile_atlas(tile_type)
	var atlas = tilemap.tile_set.get_source(tile.atlas_id)
	tile.scene_id = atlas.get_scene_tile_id(randi() % atlas.get_scene_tiles_count())
	return tile


func get_tile_center(x: int, y: int) -> Vector2:
	var ts = tilemap.tile_set.tile_size
	return Vector2(x * ts.x + ts.x / 2, y * ts.y + ts.y / 2)


func select_flying_threat_position(view_rect: Rect2i, y: int) -> Vector2:
	var ts = tilemap.tile_set.tile_size
	if randi_range(0, 1) == 0:
		@warning_ignore("integer_division")
		return get_tile_center(view_rect.position.x / ts.x - 4, y)
	return get_tile_center(view_rect.end.x / ts.x + 4, y)


func select_wall_tile(x: int, y: int) -> Tile:
	if y > WALL_START_Y:
		return null
	var tile = Tile.new()
	tile.atlas_id = walls_atlas_id
	tile.coords.y = walls_tile_type 
	if y % frieze_y_step == 0:
		tile.coords.y = frieze_tile_type
	if x == -half_width:
		tile.coords.x = Utils.random_choice(level_template.tiles.walls.left)
	elif x == half_width:
		tile.coords.x = Utils.random_choice(level_template.tiles.walls.right)
	elif randi_range(0, 19) == 0:
		tile.coords.x = Utils.random_choice(level_template.tiles.walls.secondary)
	else:
		tile.coords.x = Utils.random_choice(level_template.tiles.walls.main)
	return tile


func select_window_tile(x: int, y: int) -> Tile:
	if y % frieze_y_step == 0:
		if windows_pattern_y - y == windows_change_step:
			regenerate_windows_pattern()
			windows_pattern_y = y
		return null
	if y % WINDOW_Y_GAP != 0 or x == -half_width or x == half_width:
		return null
	return windows_pattern[x + half_width]


func select_small_window_tile(x: int, y: int) -> Tile:
	if y % frieze_y_step == 0 or y % WINDOW_Y_GAP != 0 or \
			x == -half_width or x == half_width or randi_range(0, 100) != 0:
		return null
	var tile = Tile.new()
	tile.atlas_id = windows_atlas_id
	tile.scene_id = Utils.random_choice(level_template.tiles.windows.small)
	tile.is_obstacle_allowed = false
	return tile


func select_decor_tile(_x: int, y: int) -> Tile:
	if y > WINDOW_START_Y or randi_range(0, 79) != 0:
		return null
	var tile = Tile.new()
	tile.atlas_id = level_template.random_tile_atlas(LevelTemplate.TileType.DECOR)
	var tiles_count = tilemap.tile_set.get_source(tile.atlas_id).get_tiles_count()
	tile.coords = Vector2i(randi() % tiles_count, 0)
	return tile


func select_wall_obstacle_tile(_x: int, y: int) -> Tile:
	if y > WINDOW_START_Y or randi_range(0, 79) != 0:
		return null
	return random_scene_tile(LevelTemplate.TileType.WALL_OBSTACLES)


func select_window_obstacle_tile(_x: int, _y: int) -> Tile:
	if randi_range(0, 6) != 0:
		return null
	return random_scene_tile(LevelTemplate.TileType.WINDOW_OBSTACLES)


func select_client_tile(x: int, y: int) -> Tile:
	if y > next_client_coords.y or x != next_client_coords.x:
		return null
	
	# клиенты могут появлятся только на месте оконных тайлов
	var window_tile = select_window_tile(x, y)
	if not window_tile or not window_tile.is_obstacle_allowed:
		return null
	
	next_client_coords = generate_next_client_coords(y)
	return random_scene_tile(LevelTemplate.TileType.CLIENTS)
