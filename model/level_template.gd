class_name LevelTemplate

enum ThreatType {FALLING, FLYING}
enum TileType {WALLS, WINDOWS, DECOR, WALL_OBSTACLES, WINDOW_OBSTACLES, CLIENTS}


# Структура для хранения координат стеновых тайлов
class WallTilePack:
	var left: Array[int] = []
	var right: Array[int] = []
	var main: Array[int] = []
	var secondary: Array[int] = []


# Структура для хранения координат оконных тайлов
class WindowTilePack:
	var full: Array[int] = []
	var small: Array[int] = []


# Структура для хранения координат стеновых и оконных тайлов
class TilePack:
	var walls: WallTilePack = WallTilePack.new()
	var windows: WindowTilePack = WindowTilePack.new()


## Район в котором уровень расположен
var region: Region

## Базовая сцена уровня
var scene: PackedScene

## Ширина уровня в тайлах
var width: int

## Расстояние между клиентами в этажах
var floors_between_clients: int

## Сцены с возможными угрозами на уровне (птицы и падающие предметы)
var threats = {
	ThreatType.FALLING: [],
	ThreatType.FLYING: [],
}

## Идентификаторы атласов с тайлами
var tile_atlases = {
	TileType.WALLS: [],
	TileType.WINDOWS: [],
	TileType.DECOR: [],
	TileType.WALL_OBSTACLES: [],
	TileType.WINDOW_OBSTACLES: [],
	TileType.CLIENTS: []
}

## Координаты различных тайлов в атласах (левый край здания, большое окно, маленькое окно и т.п.)
var tiles: TilePack = TilePack.new()


func instantiate(task: Task) -> Node:
	var level = scene.instantiate()
	level.init(task)
	var tile_map = level.get_node("TileMap")
	tile_map.task = task
	tile_map.level_template = self
	return level


func random_threat(threat_type: ThreatType) -> Node:
	return Utils.random_choice(threats[threat_type]).instantiate()


func random_tile_atlas(tile_type: TileType) -> int:
	return Utils.random_choice(tile_atlases[tile_type])


func init(parent_region: Region, data: Dictionary):
	region = parent_region
	
	# загружаем ширину уровня
	if 'width' not in data or not data.width:
		push_error("LevelTemplate without 'width' is invalid")
		return null
	width = data.width

	# загружаем расстояние между клиентами
	if 'floors_between_clients' not in data or not data.floors_between_clients:
		push_error("LevelTemplate without 'floors_between_clients' is invalid")
		return null
	floors_between_clients = data.floors_between_clients

	# загружаем сцену уровня
	if 'scene' not in data or not data.scene:
		push_error("LevelTemplate without 'scene' is invalid")
		return null
	scene = region.load_resource(data.scene)
	if not scene:
		return null

	# загружаем ID атласов тайлов
	if 'tile_atlases' not in data or not data.tile_atlases:
		push_error("LevelTemplate without 'tile_atlases' is invalid")
		return null
	for tile_type in TileType.values():
		var tile_type_name = TileType.find_key(tile_type).to_lower()
		if tile_type_name not in data.tile_atlases:
			push_error("LevelTemplate is missing 'tile_atlases.%s' list" % [tile_type_name])
			return null
		tile_atlases[tile_type].assign(data.tile_atlases[tile_type_name])
	
	### загружаем координаты тайлов
	if 'tiles' not in data or not data.tiles:
		push_error("LevelTemplate without 'tiles' field is invalid")
		return null
		
	# загружаем координаты стеновых тайлов
	if 'walls' not in data.tiles or not data.tiles.walls:
		push_error("LevelTemplate without 'tiles.walls' field is invalid")
		return null
	for field in ['left', 'right', 'main', 'secondary']:
		if field not in data.tiles.walls or not data.tiles.walls[field]:
			push_error("LevelTemplate without 'tiles.walls.%s' list is invalid" % [field])
			return null
	tiles.walls.left.assign(data.tiles.walls.left)
	tiles.walls.right.assign(data.tiles.walls.right)
	tiles.walls.main.assign(data.tiles.walls.main)
	tiles.walls.secondary.assign(data.tiles.walls.secondary)
	
	# загружаем координаты оконных тайлов
	if 'windows' not in data.tiles or not data.tiles.windows:
		push_error("LevelTemplate without 'tiles.windows' field is invalid")
		return null
	for field in ['full', 'small']:
		if field not in data.tiles.windows or not data.tiles.windows[field]:
			push_error("LevelTemplate without 'tiles.windows.%s' list is invalid" % [field])
			return null
	tiles.windows.full.assign(data.tiles.windows.full)
	tiles.windows.small.assign(data.tiles.windows.small)
	
	# загружаем угрозы
	if 'threats' not in data or not data.threats:
		push_error("LevelTemplate without 'threats' field is invalid")
		return null	
	for threat_type in ThreatType.values():
		var threat_type_name = ThreatType.find_key(threat_type).to_lower()
		if threat_type_name not in data.threats:
			push_error("LevelTemplate is missing 'threats.%s' list" % [threat_type_name])
			return null
		for threat_path in data.threats[threat_type_name]:
			var threat = region.load_resource(threat_path)
			if not threat:
				return null
			threats[threat_type].append(threat)
