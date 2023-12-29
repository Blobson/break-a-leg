class_name PlantBite extends DamageEffect

var position: Vector2


func apply(courier: Courier):
	courier.disable_input()
	courier.animations.position = courier.to_local(position)
	courier.animations.visible = true
	courier.animations.play("plant-bite")
	courier.animations.animation_finished.connect(func(): _on_animation_end(courier), CONNECT_ONE_SHOT)


func _on_animation_end(courier: Courier):
	courier.enable_input()
	courier.animations.visible = false
	courier.animations.position = Vector2.ZERO
	finished.emit(courier)	
