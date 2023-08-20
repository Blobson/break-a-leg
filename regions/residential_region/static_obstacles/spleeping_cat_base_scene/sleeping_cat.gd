extends BaseStaticObstacle


func _on_body_entered(body: Node):
	if body.name == "Courier":
		_deploy_to_target(body)
	super(body)


func _deploy_to_target(body):
	var cat_position_x = $'.'.global_transform.origin.x
	var courier_position_x = body.get_global_position().x
	if courier_position_x > cat_position_x:
		$Sprite2D.flip_h = true
