class_name DamageEffect extends Node


signal finished(courier: Courier)
var speed_recovery_time: float = 1.


func _init():
	finished.connect(recover)


func apply(courier: Courier):
	courier.enable_slowdown()
	finished.emit(courier)


func recover(courier: Courier):
	courier.player.play("recovery")
	courier.player.queue("run")
	courier.recover_speed(speed_recovery_time)
