class_name CarpetEntangled extends DamageEffect

var carpet_dropped_scene = preload("carpet_dropped.tscn")


func apply(courier: Courier):
	courier.disable_input()
	courier.player.play("carpet-entangled")
	courier.player.animation_finished.connect(func(_a): _on_animation_end(courier), CONNECT_ONE_SHOT)


func _on_animation_end(courier: Courier):
	courier.enable_input()
	var carpet = carpet_dropped_scene.instantiate()
	var parent = courier.get_parent()
	parent.add_child(carpet)
	carpet.position = courier.position
	finished.emit(courier)
