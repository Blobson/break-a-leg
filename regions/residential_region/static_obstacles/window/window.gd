extends BaseStaticObstacle


func _on_damage_done():
	$Sprite2D.frame += 1
