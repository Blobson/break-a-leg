extends AnimatedSprite2D


func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed:
		if get_rect().has_point(to_local(event.position)):
			_show_menu()


func get_rect() -> Rect2:
	var size = sprite_frames.get_frame_texture(animation, frame).get_size()
	var pos = offset
	if centered:
		pos -= 0.5 * size
	return Rect2(pos, size)


func _show_menu():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(30, 30), 0.3)
	tween.finished.connect(func(): 	Game.show_phone_menu())
