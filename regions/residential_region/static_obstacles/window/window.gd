extends BaseStaticObstacle


func _on_damage_apply(courier: Courier):
	play_breaking_sound(randi_range(1,2))
	super(courier)


func _on_damage_done():
	var broken_animation: String = "broken_%d" % randi_range(1, 3)
	player.play(broken_animation)


func play_breaking_sound(variety: int):
	get_node("SoundFX%d" % variety).set_pitch_scale(randf_range(0.9, 1.3))
	get_node("SoundFX%d" % variety).play()
