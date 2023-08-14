class_name WindowWithThornyyPlant extends BaseStaticObstacle

@export var damage: int = 5

func _on_body_entered(body: Node):
	super._on_body_entered(body)
	if body.has_method("take_damage"):
		body.take_damage(damage)
