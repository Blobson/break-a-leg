class_name Grandma extends BaseStaticObstacle


func _ready():
	super()
	$Sprite2D.flip_h = randi_range(0, 1)
	$ActivateTimer.timeout.connect(_on_activate_timer_timeout)
	$DustDamageArea.body_entered.connect(_on_damage_area_body_entered)


func _on_activate_timer_timeout():
	player.play('grandma_is_shaking_the_rug')
	$SoundFX1.set_pitch_scale(randf_range(0.9, 1.2))
	$SoundFX1.play()


func _on_body_entered(body: Node):
	super(body)
	$DustDamageArea.visible = false


func _on_damage_area_body_entered(body: Node):
	var courier = body if body is Courier else body.get_parent()
	if not courier is Courier:
		return

	courier.take_damage(damage, null)

