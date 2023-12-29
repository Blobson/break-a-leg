extends AudioStreamPlayer2D


func _ready():
	$QuackTimer.start(2)


func _on_quack_timer_timeout():
	self.set_pitch_scale(randf_range(0.9, 1.3))
	self.play()


func _on_finished():
	$QuackTimer.start(randf_range(10, 20))
