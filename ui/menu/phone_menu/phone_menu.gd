extends PanelContainer

const PANE_SLIDE_TIME = 0.7
@onready var contents = $VBoxContainer/Contents
var tween: Tween


func _ready():
	$VBoxContainer/PhoneToolbar.back_pressed.connect(func(): _exit_menu())
	$VBoxContainer/PhoneToolbar.shop_pressed.connect(func(): _show_pane(0))
	$VBoxContainer/PhoneToolbar.tasks_pressed.connect(func(): _show_pane(1))
	$VBoxContainer/PhoneToolbar.rating_pressed.connect(func(): _show_pane(2))


func _exit_menu():
	Game.show_main_screen()


func _show_pane(index: int):
	var pane_width = contents.size.x / contents.get_child_count()
	if tween and tween.is_running():
		tween.kill()
	var last_offset_x = contents.position.x
	var new_offset_x = pane_width - index * pane_width
	var time = PANE_SLIDE_TIME * abs(last_offset_x - new_offset_x) / pane_width
	tween = create_tween()
	tween.tween_property(contents, "position:x", new_offset_x, time) \
		.set_ease(Tween.EASE_IN_OUT) \
		.set_trans(Tween.TRANS_CUBIC)
