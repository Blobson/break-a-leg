extends Node


func random_choice(list: Array):
	return list[randi() % list.size()] if list else null


func get_view_rect() -> Rect2i:
	var camera = get_viewport().get_camera_2d() as GameCamera
	return camera.get_visible_rect()
