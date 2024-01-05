extends AnimatedSprite2D


func _ready():
	var dir = Vector2.DOWN.rotated(deg_to_rad(randi_range(-5, 5)))
	var tween = create_tween()
	tween.tween_property(self, "position", position + dir * 300, 10)
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
