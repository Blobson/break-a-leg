class_name FlyingBird extends BaseDynamicObstacle



func _ready():
	$Sprite2D.flip_h = _get_sprite_flip()
	super()



func _physics_process(delta):
	$Sprite2D.flip_h = _get_sprite_flip()
	super(delta)


func _get_sprite_flip():
	var tx = path_follow.get_parent().get_curve().sample_baked_with_rotation(path_follow.progress)
	return tx.y.x > 0
