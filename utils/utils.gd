extends Node


func random_choice(list: Array):
	return list[randi() % list.size()] if list else null


func get_view_rect() -> Rect2i:
	var camera = get_viewport().get_camera_2d() as Camera2D
	var ctrans = camera.get_canvas_transform()
	return Rect2i(
		-ctrans.get_origin() / ctrans.get_scale(), 
		camera.get_viewport_rect().size / ctrans.get_scale()
	)


func get_view_center() -> Vector2:
	var camera = get_viewport().get_camera_2d() as Camera2D
	return camera.get_screen_center_position()


func get_camera_rect() -> Rect2i:
	var camera = get_viewport().get_camera_2d() as Camera2D
	return camera.get_viewport_rect()


func to_camera_coords(pos: Vector2) -> Vector2:
	var camera = get_viewport().get_camera_2d() as Camera2D
	var ctrans = camera.get_canvas_transform()
	return ctrans * pos
	
	
func get_map_width(tile_map: TileMap):
	var map_rect = tile_map.get_used_rect()
	return map_rect.size.x * tile_map.tile_set.tile_size.x
