class_name TaskList extends ScrollContainer

const TASKS_UPDATE_INTERVAL = 1
const MAX_TASKS = 12

var task_list_item_scene = preload("./task_list_item.tscn")

## Таймер обновления задач
var tasks_update_timer = Timer.new()

## Конкуренция на рынке курьеров от 1 до MAX_COMPETITION
## Чем выше конкуренция, тем:
##   - меньше заданий в списке
##   - меньше зароботок курьера
##   - быстрее торгуются задания
var competition = 0

## Текущая ставка игрока
var player_bid: TaskListItem


func _init():
	# Конкуренция определяется случайным образом при открытии списка, 
	# в дальнейшем можно привязать к игровому времени суток
	competition = randi_range(1, Task.MAX_COMPETITION)
	tasks_update_timer.one_shot = false
	tasks_update_timer.timeout.connect(_update_tasks)


func _ready():
	_generate_tasks()
	add_child(tasks_update_timer)
	tasks_update_timer.start(TASKS_UPDATE_INTERVAL)


func _generate_tasks():
	var existing_tasks_count = $VBoxContainer.get_child_count()
	@warning_ignore("integer_division")
	var expected_tasks_count = MAX_TASKS - competition * MAX_TASKS / (Task.MAX_COMPETITION + 1)
	var new_tasks_count = max(0, expected_tasks_count - existing_tasks_count + randi_range(0, 1))
	for i in new_tasks_count:
		_generate_task()


func _generate_task():
	var last = null
	if $VBoxContainer.get_child_count() > 0:
		last = $VBoxContainer.get_child($VBoxContainer.get_child_count() - 1)
	var item = task_list_item_scene.instantiate()
	item.task = Task.generate(Game.rating)
	item.task_list = self
	$VBoxContainer.add_child(item)
	if last:
		last.focus_neighbor_bottom = item.get_path()
		item.focus_neighbor_top = last.get_path()


func _update_tasks():
	var max_bid = 0
	var max_difficulty = 0
	
	for task in $VBoxContainer.get_children():
		max_bid = max(task.task.current_bid(), max_bid)
		max_difficulty = max(task.task.difficulty, max_difficulty)
	
	for task in $VBoxContainer.get_children():
		task.update(competition, max_bid, max_difficulty)
	
	_generate_tasks()
