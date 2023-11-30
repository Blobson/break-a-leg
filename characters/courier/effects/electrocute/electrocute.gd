class_name Electrocute extends DamageEffect


func apply(courier: Courier):
	courier.player.play('electrocute')
	courier.ignore_input = true
	courier.player.animation_finished.connect(func(_e): _on_animation_end(courier), CONNECT_ONE_SHOT)
	courier.enable_slowdown()


func _on_animation_end(courier: Courier):
	courier.ignore_input = false
	courier.disable_slowdown()
	courier.player.play('run')
	finished.emit(courier)
