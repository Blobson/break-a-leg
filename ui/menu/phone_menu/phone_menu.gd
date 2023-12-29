extends PanelContainer

const PANE_SLIDE_TIME = 0.7
@onready var contents = $Frame/Contents
var tween: Tween


func _ready():
	$Frame/Contents/ShopPane/Header/BackButton.pressed.connect(func(): _exit_menu())
	$Frame/Contents/TasksPane/Header/BackButton.pressed.connect(func(): _exit_menu())
	$Frame/Contents/RatingPane/Header/BackButton.pressed.connect(func(): _exit_menu())
	$CanvasLayer/PhoneToolbar.shop_pressed.connect(func(): _show_pane(0))
	$CanvasLayer/PhoneToolbar.tasks_pressed.connect(func(): _show_pane(1))
	$CanvasLayer/PhoneToolbar.rating_pressed.connect(func(): _show_pane(2))


func _exit_menu():
	$ButtonBackPressed.play()


func _on_button_back_pressed_finished():
	Game.call_deferred("show_main_screen")


func _show_pane(index: int):
	$ButtonPressed.play()
	var panes_count = contents.get_child_count()
	if tween and tween.is_running():
		tween.kill()
	var time = PANE_SLIDE_TIME * abs(anchor_left + index)
	tween = create_tween() \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "anchor_left", -index, time)
	tween.parallel().tween_property(self, "anchor_right", -index + panes_count, time)
