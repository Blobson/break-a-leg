extends AnimatedSprite2D

func _ready():
	self.set_animation("waiting")
	_set_missed_area(Utils.get_map_width(get_parent()))

func _set_missed_area(level_width: int):
	var rect = $MissedArea/CollisionShape2D.shape as RectangleShape2D
	rect.size.x = level_width * 2

func _on_deliver_area_body_entered(body):
	if body is Courier:
		Game.delivery.emit(true)
		$MissedArea.set_monitoring(false)
		self.set_animation("receiving")

func _on_deliver_area_body_exited(body):
	if body is Courier:
		self.set_animation("complete")

func _on_missed_area_body_exited(body):
	if body is Courier:
		Game.delivery.emit(false)
