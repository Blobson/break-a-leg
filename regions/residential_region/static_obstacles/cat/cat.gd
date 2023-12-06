class_name Cat extends BaseStaticObstacle

var courier_nearby: Courier


func _ready():
	super()
	$Sprite2D.flip_h = randi_range(0, 1) == 0
	$ProximityZone.body_entered.connect(_on_body_entered_proximity_zone)
	$ProximityZone.body_exited.connect(_on_body_exited_proximity_zone)
	$FightZone.body_entered.connect(_on_body_entered_fight_zone)


func _physics_process(_delta):
	if courier_nearby:
		_rotate_to_target(courier_nearby)


func _on_body_entered_proximity_zone(body: Node):
	if not is_instance_of(body, Courier):
		return
	
	courier_nearby = body
	_rotate_to_target(body)
	
	if player.current_animation == "idle" and player.has_animation("awake"):
		player.play("awake")
		if player.has_animation("alert"):
			player.queue("alert")


func _on_body_exited_proximity_zone(body: Node):
	if body == courier_nearby:
		courier_nearby = null


func _on_damage_apply(_courier: Courier):
	if _courier.invulnerability:
		return
	$ProximityZone.set_deferred("monitoring", false)
	$Area2D.set_deferred("monitoring", false)
	if sprite.flip_h:
		player.play("jump_right")
	else:
		player.play("jump_left")
	
	player.animation_finished.connect(func(_a): _fall(), CONNECT_ONE_SHOT)


func _on_body_entered_fight_zone(body: Node):
	if not body is Courier:
		return
	
	sprite.visible = false
	$FightZone.set_deferred("monitoring", false)
	
	if player.is_playing():
		player.stop()
		player.clear_queue()
	
	var damage_effect = Fight.new()
	damage_effect.finished.connect(_on_fight_end, CONNECT_ONE_SHOT)
	body.take_damage(damage, damage_effect)


func _on_fight_end(courier: Courier):
	position = get_parent().to_local(courier.global_position)
	position.x += 10 * (-1 if sprite.flip_h else 1)
	_fall()


func _fall():
	var dir = Vector2(0.15 * (1 if sprite.flip_h else -1), 1)

	var tween = create_tween()
	tween.tween_property(self, "position", position + dir * 600, 4)
	tween.finished.connect(queue_free)
	
	player.play("fall")
	sprite.visible = true
