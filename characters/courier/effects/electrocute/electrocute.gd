class_name Electrocute extends DamageEffect

const SOUND_FX_ELECTROCUTE = preload("res://characters/courier/effects/electrocute/audio/electrocute.ogg")

func _init():
	finished.connect(recover)
	
func apply(courier: Courier):
	courier.soundfx1.set_stream(SOUND_FX_ELECTROCUTE)
	courier.soundfx1.set_volume_db(-2)
	courier.soundfx1.play()
	courier.player.play('electrocute')
	courier.ignore_input = true
	courier.player.animation_finished.connect(func(_e): _on_animation_end(courier), CONNECT_ONE_SHOT)
	courier.enable_slowdown()


func _on_animation_end(courier: Courier):
	courier.ignore_input = false
	courier.player.play('run')
	finished.emit(courier)
