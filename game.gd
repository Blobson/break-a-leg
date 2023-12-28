extends Node

signal coins_updated(from: int, to: int)
signal rating_updated(from: int, to: int)
signal health_updated(from: int, to: int)
signal energy_updated(from: int, to: int)
signal energy_reserve_updated(from: int, to: int)
signal level_start(width: int, tile_size: Vector2i)
signal level_end(level_status: LevelStatus)
signal delivery(complete: bool)
signal score_updated(from: int, to: int)
signal task_accepted(task: Task)
signal new_client(position: Vector2i)
signal shield_activate()
signal jetpack_activate()
signal package_max_count(int)

const MAIN_SCREEN = preload("res://ui/main_screen/main_screen.tscn")
const PHONE_MENU = preload("res://ui/menu/phone_menu/phone_menu.tscn")

var level_width: int

## Рейтинг игрока
var rating: int = 0 :
	set(value):
		if value < 0:
			value = 0		
		if rating != value:
			var old = score
			rating = value
			rating_updated.emit(old, rating)


## Очки
var score: int = 0 :
	set(value):
		if value < 0:
			value = 0
		if score != value:
			var old = score
			score = value
			score_updated.emit(old, score)


## Монетки 
var coins: int = 0 :
	set(value):
		if value < 0:
			value = 0
		if coins != value:
			var old = coins
			coins = value
			coins_updated.emit(old, coins)


func _init():
	task_accepted.connect(_start_level)


func show(scene: Node):
	var current_scene = get_tree().current_scene
	if current_scene:
		get_tree().root.remove_child(current_scene)
		current_scene.queue_free()
	get_tree().root.call_deferred("add_child", scene)
	get_tree().call_deferred("set_current_scene", scene)


func show_main_screen():
	show(MAIN_SCREEN.instantiate())


func show_phone_menu():
	show(PHONE_MENU.instantiate())


func _start_level(task: Task):
	score = 0
	
	# select level template
	var level_template = task.address.region.random_level_template()
	
	# show level
	show(level_template.instantiate(task))
	

## Выход из игры
func quit():
	get_tree().quit()
