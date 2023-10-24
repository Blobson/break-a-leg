class_name BaseFlyingThreat extends BaseStaticObstacle

const MAX_SPEED_DRIFT = 10
const MAX_POSITION_Y_DRIFT = 15.0
const MAX_VELOCITY_DRIFT_DEG = 10.0

@onready var path_follow = get_parent()
@export var speed = 50

var fly_limits: FlyLimits
var velocity: Vector2
var initial_y: float


func _ready():
	super()
	initial_y = position.y
	velocity = Vector2(speed + randf_range(-MAX_SPEED_DRIFT, MAX_SPEED_DRIFT), 0)
	if abs(position.x - fly_limits.left) > abs(position.x - fly_limits.right):
		velocity.x = -velocity.x
	_detect_flip()
	$VelocityUpdateTimer.timeout.connect(_update_velocity)


func _update_velocity():
	if abs(position.y - initial_y) >= MAX_POSITION_Y_DRIFT:
		velocity.y = -velocity.y
		return
	var dy = randi_range(-1, 1) * (MAX_VELOCITY_DRIFT_DEG / 4.0)
	velocity = velocity.rotated(deg_to_rad(dy))
	$Sprite2D.rotation = Vector2.LEFT.angle_to(velocity) if velocity.x < 0 else Vector2.RIGHT.angle_to(velocity)


func _detect_flip():
	$Sprite2D.flip_h = velocity.x > 0


func _physics_process(delta):
	position += velocity * delta
	if position.x >= fly_limits.right:
		position.x = fly_limits.right - 1
		velocity.x = -velocity.x
		_detect_flip()
	elif position.x <= fly_limits.left:
		position.x = fly_limits.left + 1
		velocity.x = -velocity.x
		_detect_flip()
		

func _on_damage_done():
	queue_free()


func set_fly_limits(level_fly_limits: FlyLimits):
	fly_limits = level_fly_limits
