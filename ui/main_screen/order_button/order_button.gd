extends AnimatedSprite2D


func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed:
		# TODO: переключится на главное меню
		pass
