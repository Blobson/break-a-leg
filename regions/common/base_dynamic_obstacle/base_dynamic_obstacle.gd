class_name BaseDynamicObstacle extends BaseStaticObstacle

@onready var path_follow = get_parent()
@export var speed = 300

func _physics_process(delta):
	path_follow.set_progress(path_follow.get_progress() + speed * delta)
