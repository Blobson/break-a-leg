class_name HealthIndicator extends Node2D

@onready var size = preload("res://ui/level_ui/health_indicator/health.png").get_size() * scale * Vector2(3,1)

func _ready():
	var signal_health = get_node("/root/Game")
	signal_health.health_updated.connect(_health_changed_signal)
	_health_change(get_parent().health, 0)

func _health_change(health, old_value):
	# если новое значение жизней больше старого, то добавляем значки сердечек
	if health > old_value:
		for i in (health - old_value):
			var new_health = Sprite2D.new()
			add_child(new_health)
			new_health.set_texture(preload("res://ui/level_ui/health_indicator/health.png"))
			new_health.set_position(Vector2(i*new_health.get_texture().get_size().x + new_health.get_texture().get_size().x/2,new_health.get_texture().get_size().y/2))
	# если новое значение жизней меньше старого, то убираем сердечко
	elif health < old_value:
		for i in (old_value - health):
			var new_health = get_children()
			remove_child(new_health[i])
	
func _health_changed_signal(health, old_value):
	if Game.health_updated:
		_health_change(health, old_value)
