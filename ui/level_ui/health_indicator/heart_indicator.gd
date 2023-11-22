class_name HeartIndicator extends HBoxContainer

var heart_scene = preload("res://ui/level_ui/health_indicator/heart.tscn")
const HEALTH_PER_HEART = 10

func _init():
	Game.health_updated.connect(_health_change)

func _health_change(health, _old_value):
	if health < _old_value:
		Input.vibrate_handheld(1000)
	var needed_hearts = ceil(health / float(HEALTH_PER_HEART))
	var existing_hearts = 0
	for heart in get_children():
		if heart.state != Heart.State.EMPTY:
			existing_hearts += 1
	# Удаляем лишние сердца
	while existing_hearts > needed_hearts:
		get_child(0).state = Heart.State.EMPTY
		existing_hearts -= 1
	# Добавляем недостающие сердца
	while existing_hearts < needed_hearts:
		var heart_node = heart_scene.instantiate()
		add_child(heart_node)
		get_child(0).state = Heart.State.FULL
		existing_hearts += 1
	# У крайнего сердца проставляем State Broken
	if health % HEALTH_PER_HEART != 0 and existing_hearts > 0:
		var broken_heart = null
		for heart in get_children():
			if heart.state != Heart.State.EMPTY:
				broken_heart = heart
				break
		broken_heart.state = Heart.State.BROKEN
