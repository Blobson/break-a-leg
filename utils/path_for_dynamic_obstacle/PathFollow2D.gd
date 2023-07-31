extends PathFollow2D

var DynamicObstacle = load("res://regions/common/base_dynamic_obstacle/BaseDynamicObstacle.tscn")

func _ready():
	var e = DynamicObstacle.instantiate()
	e.position = get_parent().position
	add_child(e)
