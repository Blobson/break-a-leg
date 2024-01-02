extends BaseStaticObstacle


func _on_damage_apply(courier: Courier):
	if courier.is_jumping():
		return
	
	play_breaking_sound(randi_range(1,2))
	
	courier.take_damage(damage, get_damage_effect())

	if player.has_animation("activate"):
		player.play("activate")  # анимация активации
		player.animation_finished.connect(func(a): if a == "activate": _on_damage_done(), CONNECT_ONE_SHOT)
	else:
		_on_damage_done()


func _on_damage_done():
	var broken_animation: String = "broken_%d" % randi_range(1, 3)
	player.play(broken_animation)


func play_breaking_sound(variety: int):
	get_node("SoundFX%d" % variety).set_pitch_scale(randf_range(0.9, 1.3))
	get_node("SoundFX%d" % variety).play()
