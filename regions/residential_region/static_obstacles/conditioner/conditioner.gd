extends BaseStaticObstacle


func get_damage_effect() -> DamageEffect:
	return Electrocute.new()
