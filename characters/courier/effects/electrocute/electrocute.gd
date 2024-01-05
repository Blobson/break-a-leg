class_name Electrocute extends DamageEffect

const SOUND_FX_ELECTROCUTE = preload("res://characters/courier/effects/electrocute/audio/electrocute.ogg")


func _init():
	finished.connect(recover)


func apply(courier: Courier):
	courier.soundfx1.set_stream(SOUND_FX_ELECTROCUTE)
	courier.soundfx1.set_volume_db(-2)
	courier.soundfx1.play()
	courier.player.play('electrocute')
	courier.player.animation_finished.connect(func(_a): _on_animation_end(courier), CONNECT_ONE_SHOT)
	courier.disable_input()
	courier.enable_slowdown()


func recover(courier: Courier):
	super(courier)
	courier.enable_input()


func _on_animation_end(courier: Courier):
	courier.player.queue('run')
	finished.emit(courier)

	
