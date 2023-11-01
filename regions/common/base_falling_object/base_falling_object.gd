class_name BaseFallingObject extends BaseStaticObstacle

@export var speed = 300


func _ready():
	super()
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exit)


func _physics_process(delta):
	position.y += speed * delta


func _on_damage_apply(body: Node):
	super(body)
	speed = -body.move_speed


func _on_damage_done():
	super()
	queue_free()


func _on_screen_exit():
	queue_free()
