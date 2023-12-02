extends BaseStaticObstacle


func _on_damage_done():
	var broaken_animation: String = "broken_%d" % randi_range(1, 3)
	$AnimationPlayer.play(broaken_animation)
