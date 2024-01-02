class_name BaseFallingObject extends BaseStaticObstacle

@export var speed = 300


func _ready():
	super()
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_screen_exit)


func _physics_process(delta):
	position.y += speed * delta


func _on_damage_apply(courier: Courier):
	super(courier)
	$SoundFX1.set_pitch_scale(randf_range(0.9, 1.2))
	$SoundFX1.play()
	speed = -courier.move_speed


func _on_damage_done():
	super()
	queue_free()


func _on_screen_exit():
	queue_free()
