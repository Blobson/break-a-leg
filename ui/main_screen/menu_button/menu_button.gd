extends AnimatedSprite2D


func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed:
		var tween = create_tween()
		tween.tween_property(self, "scale", Vector2(30, 30), 0.3)
		tween.finished.connect(_show_menu)


func _show_menu():
	get_tree().change_scene_to_file("res://ui/menu/phone_menu/phone_menu.tscn")