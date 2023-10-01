class_name TaskListItem extends PanelContainer

enum TaskState { AVAILABLE, SOLD, CANCELLED }

const DISAPPEAR_TIMEOUT = 2
const MIN_BID_INTERVAL = 2

@onready var _ui_address = $Frame/VBox/Address
@onready var _ui_bid = $Frame/VBox/HBox/BidBox/TaskBid

var normal_panel_style: StyleBox = get_theme_stylebox('panel')
var hover_panel_style: StyleBox = get_theme_stylebox('hover')
var address_color: Color

var task_list: TaskList
var task: Task = Task.generate(Game.rating)
var state: TaskState = TaskState.AVAILABLE
var created_at: float = 0.0
var next_bid: int = 0
var last_bid_at: float = 0.0


func _init():
	created_at = Time.get_unix_time_from_system()
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)	
	

func _ready():
	next_bid = task.start_bid()
	$Frame/VBox/HBox/RegionIcon.texture = task.address.region.icon
	$Frame/VBox/HBox/Info/Packages.text = "packages: %d" % [task.packages]
	$Frame/VBox/HBox/Info/Difficulty.text = task.difficulty_text()
	$Frame/VBox/HBox/Info/Difficulty.add_theme_color_override("font_color", task.difficulty_color())
	_ui_address.text = "%s %s" % [ task.address.building, task.address.street ]
	_ui_bid.set_bid(next_bid)
	_ui_bid.gui_input.connect(_on_bid_input)
	address_color = _ui_address.get_theme_color("font_color")


func _on_focus_entered():
	
	add_theme_stylebox_override('panel', hover_panel_style)
	_ui_address.add_theme_color_override("font_color", normal_panel_style.bg_color)
	_ui_address.add_theme_color_override("font_outline_color", Color8(255, 255, 255, 255))


func _on_focus_exited():
	add_theme_stylebox_override('panel', normal_panel_style)
	_ui_address.add_theme_color_override("font_color", address_color)
	_ui_address.remove_theme_color_override("font_outline_color")


func _disable(task_state: TaskState, text: String):
	$StatusMask.visible = true
	$StatusMask/Status.text = text
	state = task_state
	var prev_task = get_node(focus_neighbor_top) if focus_neighbor_top else null
	var next_task = get_node(focus_neighbor_bottom) if focus_neighbor_bottom else null
	if prev_task:
		prev_task.focus_neighbor_bottom = focus_neighbor_bottom
		focus_neighbor_bottom = ""
	if next_task:
		next_task.focus_neighbor_top = focus_neighbor_top
		focus_neighbor_top = ""


func _destroy():
	get_parent().remove_child(self)
	queue_free()


func _remove():
	var destroy_tween = create_tween()
	pivot_offset = size / 2.0
	destroy_tween.tween_property(self, "scale", Vector2.ZERO, 0.5)
	destroy_tween.finished.connect(_destroy)


func _cancel():
	_disable(TaskState.CANCELLED, "Cancelled by user!")
	create_tween().tween_interval(DISAPPEAR_TIMEOUT).finished.connect(_remove)


func _sold():
	var text = "Sold!"
	if task_list.player_bid == self:
		text = "You WON!"
		task_list.player_bid = null
	_disable(TaskState.SOLD, text)
	# TODO: запустить уровень, если игрок выиграл ставку
	create_tween().tween_interval(DISAPPEAR_TIMEOUT).finished.connect(_remove)


func _on_bid_input(event: InputEvent):
	if event is InputEventScreenTouch and event.pressed:
		_place_player_bid(next_bid)


func _cancel_player_bid():
	if not task_list:
		return
	if task_list.player_bid == self:
		task_list.player_bid = null
		_ui_bid.set_inactive_style()
		_place_bid(next_bid+2)


func _place_player_bid(bid: int):
	if not task_list or task_list.player_bid == self:
		return
	if task_list.player_bid:
		task_list.player_bid._cancel_player_bid()
	task_list.player_bid = self
	_ui_bid.set_active_style()
	_place_bid(bid)


func _place_bid(bid: int):
	var start_bid = task.start_bid()
	if bid > start_bid:
		bid = start_bid
	task.bid = bid
	last_bid_at = Time.get_unix_time_from_system()
	next_bid = bid - 1
	_ui_bid.update(bid)


func update(competition: int, max_bid: int, max_difficulty: int):
	if state != TaskState.AVAILABLE:
		return
	
	var now = Time.get_unix_time_from_system()
	var updated_at = last_bid_at if last_bid_at else created_at
	
	if last_bid_at:
		_ui_bid.update_progress(now - last_bid_at)
	
	if task.check_cancel_probability(updated_at):
		return _cancel()
	
	if now - last_bid_at >= MIN_BID_INTERVAL and task.check_bid_probability(competition, max_bid, max_difficulty):
		if task_list and task_list.player_bid == self:
			_cancel_player_bid()
		_place_bid(next_bid)

	if task.check_sell_condition(last_bid_at):
		_sold()
