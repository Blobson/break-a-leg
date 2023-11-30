class_name BitingPlant extends BaseStaticObstacle

var courier_nearby: Courier

func _ready():
	super()
	$Sprite2D.flip_h = randi_range(0, 1) == 0
	$ProximityZone.body_entered.connect(_on_body_entered_proximity_zone)
	$ProximityZone.body_exited.connect(_on_body_exited_proximity_zone)


func _physics_process(_delta):
	if courier_nearby:
		_rotate_to_target(courier_nearby)


func _on_body_entered_proximity_zone(body: Node):
	if not is_instance_of(body, Courier):
		return
	
	
	courier_nearby = body
	if body.global_position.x > self.global_position.x and $Sprite2D.flip_h != true:
		$AnimationPlayer.play('turn_right')
	elif body.global_position.x < self.global_position.x and $Sprite2D.flip_h == true:
		$AnimationPlayer.play('turn_right', 0.5, 0.5, true)   #Анимация проигрывается с её конца => поворот цветка справа налево
	_rotate_to_target(body)


func _on_body_exited_proximity_zone(body: Node):
	if body == courier_nearby:
		courier_nearby = null

