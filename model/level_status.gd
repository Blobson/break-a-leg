class_name LevelStatus
##Хранит статистику прохождения уровня и оценивает качество прохождения

var task: Task

const MAX_STARS: int = 5

var is_success: bool
var stars_count: int

var alive: bool = true
var target_delivery_count: int
var current_delivery_count: int = 0
var missed_deliveries: int = 0
var current_coins: int = 0

func init(new_task: Task):
	task = new_task
	target_delivery_count = new_task.packages

func delivered(complete: bool):
	if complete:
		current_delivery_count += 1
		current_coins += task.PACKAGE_PRICE
	else:
		missed_deliveries += 1
	
func dead():
	alive = false
	
func on_level_end():
	if alive:
		current_coins += task.bid
		@warning_ignore("integer_division")
		stars_count = MAX_STARS * current_delivery_count / target_delivery_count if current_delivery_count > 0 else 0
	else:
		current_coins /= 2
		stars_count = 0
