extends BaseStaticObstacle


func _ready():
	super()
	$SoundFX1.set_pitch_scale(randf_range(0.9, 1.2))
	$SoundFX1.play()


func _on_damage_apply(courier: Courier):
	super(courier)
	$SoundFX2.play()
	$SoundFX1._set_playing(false)


func get_damage_effect() -> DamageEffect:
	return Electrocute.new()
