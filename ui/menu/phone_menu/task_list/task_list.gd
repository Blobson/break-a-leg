class_name TaskList extends ScrollContainer

const MAX_TASKS_UPDATE_INTERVAL = 3
const MAX_TASKS = 10
const MINIMAL_BID = 5

var task_list_item_scene = preload("res://ui/menu/phone_menu/task_list/task_list_item.tscn")
var tasks_update_timer = Timer.new()
var rnd = RandomNumberGenerator.new()


func _init():
	tasks_update_timer.one_shot = true
	tasks_update_timer.timeout.connect(_update_tasks)


func _ready():
	_generate_tasks()
	add_child(tasks_update_timer)
	_start_update_timer()


func _start_update_timer():
	var interval = rnd.randi_range(1, MAX_TASKS_UPDATE_INTERVAL)
	tasks_update_timer.start(interval)


func _generate_task():
	var last = null
	if $VBoxContainer.get_child_count() > 0:
		last = $VBoxContainer.get_child($VBoxContainer.get_child_count() - 1)
	var item = task_list_item_scene.instantiate()
	item.task = Task.generate(rnd, Game.rating)
	$VBoxContainer.add_child(item)
	if last:
		last.focus_neighbor_bottom = item.get_path()
		item.focus_neighbor_top = last.get_path()

func _generate_tasks():
	for i in rnd.randi_range(MAX_TASKS / 2, MAX_TASKS):
		_generate_task()
	var last: TaskListItem = null
	for item in $VBoxContainer.get_children():
		if last:
			last.focus_neighbor_bottom = item.get_path()
			item.focus_neighbor_top = last.get_path()


func _update_tasks():
	# expire tasks with small bids
	var expired = []
	for item in $VBoxContainer.get_children():
		if item.task.bid <= MINIMAL_BID:
			expired.append(item)
	
	for item in expired: 
		var prev_item = get_node(item.focus_neighbor_top)
		var next_item = get_node(item.focus_neighbor_bottom)
		if prev_item:
			prev_item.focus_neighbor_bottom = item.focus_neighbor_bottom
		if next_item:
			next_item.focus_neighbor_top = item.focus_neighbor_top
		$VBoxContainer.remove_child(item)
		item.queue_free()
		# TODO: add animation for disappearing tasks
	
	# update task bids
	for _i in rnd.randi_range(1, 3):
		var item = $VBoxContainer.get_child(rnd.randi_range(0, $VBoxContainer.get_child_count()-1))
		item.update_bid(item.task.bid - rnd.randi_range(1, 3))

	# generate new tasks
	if $VBoxContainer.get_child_count() <= MAX_TASKS - 3:
		for _i in rnd.randi_range(0, 3):
			_generate_task()
		
	_start_update_timer()
