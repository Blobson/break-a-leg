class_name Dusty extends DamageEffect

func recover(courier: Courier):
	courier.player.play("dusty")
	courier.player.queue("run")
	courier.recover_speed(speed_recovery_time)

