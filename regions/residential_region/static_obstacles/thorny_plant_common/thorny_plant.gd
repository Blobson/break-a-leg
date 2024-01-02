class_name ThornyPlant extends BaseStaticObstacle 

func _on_damage_apply(courier: Courier):
	courier.take_damage(damage, get_damage_effect())
	$SoundFX1.set_pitch_scale(randf_range(0.9, 1.1))
	$SoundFX1.play()
	
	player.play("activate")  # анимация активации
	player.animation_finished.connect(func(a): if a == "activate": _on_damage_done(), CONNECT_ONE_SHOT)
