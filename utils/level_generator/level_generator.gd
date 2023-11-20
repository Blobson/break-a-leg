extends TileMap

enum Layer {WALLS, DECOR, WINDOWS, OBSTACLES}

# NOTE: Параметры task и level_template проставляются в LevelTemplate.instantiate(...)
var task: Task
var level_template: LevelTemplate

var tile_generator: TileGenerator = TileGenerator.new()


func _ready():
	# DEBUG: Для отладки задаём параметры вручную, если генератор был запущен отдельно от игры
	if not task or not level_template:
		task = Task.generate(1)
		level_template = task.address.region.random_level_template()
	# END OF DEBUG
	tile_generator.init(level_template, self)
	generate()
	Game.level_start.emit(level_template.width * tile_set.tile_size.x, tile_set.tile_size)
	$UpdateTimer.timeout.connect(generate)


func generate():
	var view_rect = Utils.get_view_rect()
	var target_rect = _get_generator_rect(view_rect)
	remove_passed_floors(target_rect)
	generate_floors(view_rect, target_rect)


func _get_generator_rect(view_rect: Rect2i) -> Rect2i:
	var ts = tile_set.tile_size
	var top_floor = floor(view_rect.position.y / float(ts.y)) 
	var bottom_floor = top_floor + ceil(view_rect.size.y / float(ts.y)) + 1
	top_floor -= level_template.floors_between_clients * tile_generator.WINDOW_Y_GAP
	@warning_ignore("integer_division")
	return Rect2i(
		Vector2i(-level_template.width / 2, top_floor), 
		Vector2i(level_template.width, bottom_floor - top_floor + 1)
	)


func remove_passed_floors(target_rect: Rect2i):
	var tile_rect = get_used_rect()
	var rm_rect = Rect2i(
		target_rect.position.x, target_rect.end.y, 
		target_rect.size.x, max(0, tile_rect.end.y - target_rect.end.y)
	)

	for x in range(rm_rect.position.x, rm_rect.size.x + 1):
		for y in range(rm_rect.position.y, rm_rect.size.y + 1):
			for layer in get_layers_count():
				erase_cell(layer, Vector2i(x, y))


func generate_floors(view_rect: Rect2i, target_rect: Rect2i):
	var tile_rect = get_used_rect()
	var gen_rect = Rect2i(
		target_rect.position.x, target_rect.position.y, 
		target_rect.size.x, tile_rect.position.y - target_rect.position.y
	)

	@warning_ignore("integer_division")
	var screen_top = view_rect.position.y / tile_set.tile_size.y

	for y in range(gen_rect.end.y - 1, gen_rect.position.y - 1, -1):
		# generate tiles
		for x in range(gen_rect.position.x, gen_rect.end.x):
			generate_tile(x, y)
			
			# generate falling threats above the screen top
			if y < screen_top:
				generate_falling_threat(x, y)
		
		# generate horizontal flying threats
		generate_flying_threat(view_rect, y)


func generate_tile(x: int, y: int):
	# generate wall tile
	var wall_tile = tile_generator.select_wall_tile(x, y)
	if not wall_tile:
		return
	set_cell(Layer.WALLS, Vector2i(x, y), wall_tile.atlas_id, wall_tile.coords, 0)

	# try generating client window
	var client_tile = tile_generator.select_client_tile(x, y)
	if client_tile:
		set_cell(Layer.WINDOWS, Vector2i(x, y), client_tile.atlas_id, Vector2i.ZERO, client_tile.scene_id)
		Game.new_client.emit(get_global_transform() * tile_generator.get_tile_center(x, y))
		return

	# generate window tile
	var window_tile = tile_generator.select_window_tile(x, y)
	if window_tile:
		set_cell(Layer.WINDOWS, Vector2i(x, y), window_tile.atlas_id, window_tile.coords, 0)
		# place window obstacle
		if window_tile.is_obstacle_allowed:
			var window_obstacle_tile = tile_generator.select_window_obstacle_tile(x, y)
			if window_obstacle_tile:
				set_cell(Layer.OBSTACLES, Vector2i(x, y), window_obstacle_tile.atlas_id, Vector2i.ZERO, window_obstacle_tile.scene_id)
		return

	# place wall mounted obstacle
	var wall_obstacle_tile = tile_generator.select_wall_obstacle_tile(x, y)
	if wall_obstacle_tile:
		set_cell(Layer.OBSTACLES, Vector2i(x, y), wall_obstacle_tile.atlas_id, Vector2i.ZERO, wall_obstacle_tile.scene_id)
		return

	# generate decor if no obstacle was placed on the tile
	var decor_tile = tile_generator.select_decor_tile(x, y)
	if decor_tile:
		set_cell(Layer.DECOR, Vector2i(x, y), decor_tile.atlas_id, decor_tile.coords, 0)


func generate_flying_threat(view_rect: Rect2i, y: int):
	if randi_range(0, 12) != 0:
		return
	var threat = level_template.random_threat(LevelTemplate.ThreatType.FLYING)
	threat.set_fly_limits(tile_generator.fly_limits)
	if threat:
		threat.position = tile_generator.select_flying_threat_position(view_rect, y)
		$Obstacles.add_child(threat)


func generate_falling_threat(x: int, y: int):
	if randi_range(0, 199) != 0:
		return
	var threat = level_template.random_threat(LevelTemplate.ThreatType.FALLING)
	if threat:
		threat.position = tile_generator.get_tile_center(x, y)
		$Obstacles.add_child(threat)
