class_name BitingPlant extends BaseStaticObstacle

const TURN_GAP = 10

var courier_nearby: Courier

func _ready():
	super()
	$Sprite2D.flip_h = randi_range(0, 1) == 0
	$ProximityZone.body_entered.connect(_on_body_entered_proximity_zone)
	$ProximityZone.body_exited.connect(_on_body_exited_proximity_zone)
	$BiteZone.body_entered.connect(_on_body_entered_bite_zone)

func _physics_process(_delta):
	if courier_nearby:
		_rotate_to_target(courier_nearby)


func _on_body_entered_proximity_zone(body: Node):
	if not is_instance_of(body, Courier):
		return
	courier_nearby = body
	_rotate_to_target(body)


func _on_body_exited_proximity_zone(body: Node):
	if body == courier_nearby:
		courier_nearby = null


func _on_damage_apply(courier: Courier):
	if courier.invulnerability:
		return
	$ProximityZone.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitoring", false)
	if sprite.flip_h:
		player.play("bite_right")
	else:
		player.play("bite_left")


func _on_body_entered_bite_zone(body: Node):
	if not body is Courier:
		return
	
	$BiteZone.set_deferred("monitoring", false)
	var damage_effect = PlantBite.new()
	damage_effect.position = $BiteZone.global_position
	body.take_damage(damage, damage_effect)


func _rotate_to_target(body):
	if $AnimationPlayer.is_playing() and $AnimationPlayer.current_animation == 'turn_right':
		return
	if body.global_position.x > global_position.x + TURN_GAP and not $Sprite2D.flip_h:
		$AnimationPlayer.play('turn_right')
	elif body.global_position.x < global_position.x - TURN_GAP and $Sprite2D.flip_h:
		$AnimationPlayer.play_backwards('turn_right')
