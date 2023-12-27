class_name TaskListItem extends PanelContainer

enum TaskState { AVAILABLE, SOLD, CANCELLED }

const DISAPPEAR_TIMEOUT = 0.7
const MIN_BID_INTERVAL = 2

@onready var _ui_body = $Body
@onready var _ui_bid = $Body/HBox/VBox/HBox/TaskBid
@onready var _ui_packages_box = $Body/HBox/VBox/HBox/PackagesBox
@onready var _ui_delivery_box = $Body/HBox/VBox/HBox/DeliveryBox

@onready var active_panel_style: StyleBox = $Body.get_theme_stylebox('panel_active')
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
	task_list = get_parent().get_parent()
	next_bid = task.start_bid() - 1
	$Body/HBox/AddressBox/RegionIcon.texture = task.address.region.icon
	$Body/HBox/VBox/HBox/PackagesBox/PackagesCount.text = str(task.packages)
	$Body/HBox/VBox/HBox/PackagesBox/PackageIcon1.visible = randi_range(0, 1) == 0
	$Body/HBox/VBox/HBox/PackagesBox/PackageIcon2.visible = not $Body/HBox/VBox/HBox/PackagesBox/PackageIcon1.visible
	$Body/HBox/VBox/DifficultyBox/Difficulty.text = task.difficulty_text()
	$Body/HBox/VBox/DifficultyBox/Difficulty.add_theme_color_override("font_color", task.difficulty_color())
	$Body/HBox/VBox/DifficultyBox/DifficultyIcon.play(task.difficulty_text())
	$Body/HBox/VBox/HBox/DeliveryBox/DeliverButton.pressed.connect(_on_deliver_pressed)
	$Body/HBox/VBox/HBox/TaskBid.set_bid(next_bid)
	$Body/HBox/AddressBox/Address.text = "%s %s" % [ task.address.building, task.address.street ]
	address_color = $Body/HBox/AddressBox/Address.get_theme_color("font_color")


func _on_deliver_pressed():
	_place_player_bid(next_bid)
	_sold()


func _on_focus_entered():
	_ui_packages_box.visible = false
	_ui_delivery_box.visible = true
	_ui_body.add_theme_stylebox_override("panel", active_panel_style)
	_ui_bid.set_active_style()


func _on_focus_exited():
	_ui_delivery_box.visible = false
	_ui_packages_box.visible = true
	_ui_body.remove_theme_stylebox_override("panel")
	_ui_bid.set_inactive_style()


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
	_disable(TaskState.CANCELLED, "Cancelled by client!")
	create_tween().tween_interval(DISAPPEAR_TIMEOUT).finished.connect(_remove)


func _accept_task():
	var destroy_tween = create_tween()
	pivot_offset = size / 2.0
	destroy_tween.tween_property(self, "scale", Vector2.ZERO, 0.5)	
	destroy_tween.finished.connect(func(): Game.task_accepted.emit(task))


func _sold():
	var text = "A missed opportunity!"
	var destroy_fn = _remove
	if task_list and task_list.player_bid == self:
		text = "Order accepted!"
		destroy_fn = _accept_task
	_disable(TaskState.SOLD, text)
	create_tween().tween_interval(DISAPPEAR_TIMEOUT).finished.connect(destroy_fn)


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
	
	if task.check_cancel_probability(updated_at):
		return _cancel()
	
	if now - last_bid_at >= MIN_BID_INTERVAL and task.check_bid_probability(competition, max_bid, max_difficulty):
		if task_list and task_list.player_bid == self:
			_cancel_player_bid()
		_place_bid(next_bid)

	if task.check_sell_condition(last_bid_at):
		_sold()
