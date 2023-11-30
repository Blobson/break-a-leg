class_name DamageEffect extends Node


signal finished(courier: Courier)


func apply(courier: Courier):
	finished.emit(courier)
