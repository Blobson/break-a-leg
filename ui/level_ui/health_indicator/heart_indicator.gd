class_name HeartIndicator extends HBoxContainer

var heart_scene = preload("res://ui/level_ui/health_indicator/heart.tscn")
const HEALTH_PER_HEART = 10

func _init():
	Game.health_updated.connect(_health_change)

func _health_change(health, old_value):
	var needed_hearts = ceil(health / float(HEALTH_PER_HEART))
	var existing_hearts = get_child_count()
	# Удаляем лишние сердца
	while existing_hearts > needed_hearts:
		var heart_node = get_child(0)
		remove_child(heart_node)
		heart_node.queue_free()
		existing_hearts -= 1
	# Добавляем недостающие сердца
	while existing_hearts < needed_hearts:
		var heart_node = heart_scene.instantiate()
		add_child(heart_node)
		existing_hearts += 1
	# У крайнего сердца проставляем State Broken
	if health % HEALTH_PER_HEART != 0 and existing_hearts > 0:
		get_child(0).state = Heart.State.BROKEN
