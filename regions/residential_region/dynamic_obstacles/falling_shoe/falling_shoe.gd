class_name FallingShoe extends BaseDynamicObstacle


func _ready():
	super()
	$VisibleOnScreenNotifier2D.screen_exited.connect(_screen_exited)	


func _on_body_entered(body: Node):
	super(body)
	queue_free()


func _screen_exited():
	queue_free()
