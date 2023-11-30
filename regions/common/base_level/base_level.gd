extends Node2D

var task: Task
var level_status: LevelStatus

const LEVEL_FINISH_SCENE = preload("res://ui/level_finish/level_finish.tscn")

func _ready():
	$Courier.courier_dead.connect(_on_courier_dead)
	Game.delivery.connect(_on_delivery)

func init(new_task: Task):
	task = new_task
	level_status = LevelStatus.new()
	level_status.init(task)
	
func _on_delivery(complete):
	level_status.delivered(complete)
	if level_status.current_delivery_count + level_status.missed_deliveries == level_status.target_delivery_count:
		level_end()

func _on_courier_dead():
	level_status.dead()
	level_end()
	
func level_end():
	level_status.on_level_end()
	var level_finish = LEVEL_FINISH_SCENE.instantiate()
	level_finish.on_level_end(level_status)
	Game.call_deferred("show", level_finish)
