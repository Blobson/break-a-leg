extends BaseStaticObstacle


func _ready():
	$AnimationPlayer.play("idle")
	$Area2D.body_entered.connect(_on_body_entered)
	$SoundFX1.set_pitch_scale(randf_range(0.9, 1.2))
	$SoundFX1.play()


func _on_damage_apply(courier: Courier):
	if courier.is_jumping():
		return
	super(courier)
	$SoundFX2.play()
	$SoundFX1._set_playing(false)


func get_damage_effect() -> DamageEffect:
	return Electrocute.new()
