extends BaseStaticObstacle

func _on_damage_apply(body: Node):
	if not body is Courier or body.is_jumping():
		return

	body.take_damage(damage, get_damage_effect())

	if $AnimationPlayer.has_animation("activate"):
		$AnimationPlayer.play("activate")  # анимация активации
		$AnimationPlayer.animation_finished.connect(func(a): if a == "activate": _on_damage_done(), CONNECT_ONE_SHOT)
	else:
		_on_damage_done()

func _on_damage_done():
	var broaken_animation: String = "broken_%d" % randi_range(1, 3)
	$AnimationPlayer.play(broaken_animation)
