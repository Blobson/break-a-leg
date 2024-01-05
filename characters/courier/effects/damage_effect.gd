class_name DamageEffect extends Node


signal finished(courier: Courier)
var speed_recovery_time: float = 1.


func _init():
	finished.connect(recover)


func apply(courier: Courier):
	courier.enable_slowdown()
	if courier.player.current_animation in ["run", "left", "right"]:
		finished.emit(courier)


func recover(courier: Courier):
	courier.player.clear_queue()
	if courier.player.current_animation == "run":
		courier.player.play("recovery")
	else:
		courier.player.queue("recovery")
	courier.recover_speed(speed_recovery_time)
