extends BaseStaticObstacle

func _on_damage_apply(courier: Courier):
	if courier.is_jumping():
		return
	super(courier)


func get_damage_effect() -> DamageEffect:
	return Electrocute.new()
