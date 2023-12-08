class_name Fight extends DamageEffect


func apply(courier: Courier):
	courier.disable_input()
	courier.enable_slowdown()
	courier.sprite.visible = false
	courier.animations.visible = true
	courier.animations.play("fight")
	courier.animations.animation_finished.connect(func(): _on_animation_end(courier), CONNECT_ONE_SHOT)


func _on_animation_end(courier: Courier):
	courier.enable_input()
	courier.sprite.visible = true
	courier.animations.visible = false
	finished.emit(courier)
	
