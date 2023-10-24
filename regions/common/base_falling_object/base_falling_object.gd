class_name FallingObject extends BaseStaticObstacle

@export var speed = 300


func _ready():
	super()
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exit)


func _physics_process(delta):
	position.y += speed * delta


func _on_damage_done():
	queue_free()


func _on_screen_exit():
	queue_free()
