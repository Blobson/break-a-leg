class_name BaseFlyingThreat extends BaseStaticObstacle

const MAX_SPEED_DRIFT = 10
const MAX_POSITION_Y_DRIFT = 15.0
const MAX_VELOCITY_DRIFT_DEG = 10.0

@export var speed = 50
@export var velocity_modifier = Vector2.ZERO

var fly_limits = FlyLimits.new()
var velocity: Vector2
var initial_y: float


func _ready():
	super()
	initial_y = position.y
	speed = speed + randf_range(-MAX_SPEED_DRIFT, MAX_SPEED_DRIFT)
	velocity = Vector2(speed, 0)
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
	sprite.rotation = Vector2.LEFT.angle_to(velocity) if velocity.x < 0 else Vector2.RIGHT.angle_to(velocity)


func _detect_flip():
	sprite.flip_h = velocity.x > 0


func _physics_process(delta):
	if player.is_playing() and player.current_animation == "push-back":
		return
	position += (velocity + Vector2(velocity_modifier.x if sprite.flip_h else -velocity_modifier.x, velocity_modifier.y)) * delta
	if position.x >= fly_limits.right:
		position.x = fly_limits.right - 1
		velocity.x = -velocity.x
		_detect_flip()
	elif position.x <= fly_limits.left:
		position.x = fly_limits.left + 1
		velocity.x = -velocity.x
		_detect_flip()


func get_damage_effect() -> DamageEffect:
	var hit = BirdHit.new()
	hit.position = global_position
	return hit


func _on_damage_apply(courier: Courier):
	super(courier)
	
	# Проверяем относительное расположение курьера и птицы
	if (courier.global_position.x < global_position.x and velocity.x < 0) or \
			(courier.global_position.x > global_position.x and velocity.x > 0):
		scale.x = -1.0 if sprite.flip_h else 1.0
		sprite.flip_h = false
		player.play("push-back")
	else:
		print("push-forward")
		player.play("push-forward")
		
	player.queue("idle")


func _on_damage_done():
	super()
	scale.x = 1.0
	_detect_flip()


func set_fly_limits(level_fly_limits: FlyLimits):
	fly_limits = level_fly_limits
