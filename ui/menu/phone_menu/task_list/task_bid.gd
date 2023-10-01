extends HBoxContainer

const ACTIVE_COLOR = Color8(196, 130, 0, 255)
const ACTIVE_OUTLINE_COLOR = Color8(255, 255, 255, 255)

@onready var _ui_text = $Text
@onready var _ui_progress = $ProgressBar

var accent_style: StyleBox = get_theme_stylebox('accent', 'ProgressBar')


func _ready():
	_ui_progress.min_value = 0
	_ui_progress.max_value = Task.SELL_TIMEOUT
	_ui_progress.value = 0


func update_progress(elapsed_time: float):
	if _ui_progress.value > 0:
		_ui_progress.value = _ui_progress.max_value - elapsed_time


func set_bid(bid: int):
	_ui_text.text = str(bid)


func update(bid: int):
	set_bid(bid)
	_ui_progress.value = _ui_progress.max_value
	_ui_text.pivot_offset = _get_text_center()
	var bid_tween = create_tween()
	bid_tween.tween_property(_ui_text, "scale", Vector2(1.1, 1.1), 0.15) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	bid_tween.tween_property(_ui_text, "rotation_degrees", -10, 0.15) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	var next_tween = bid_tween.chain()
	next_tween.tween_property(_ui_text, "rotation_degrees", 10, 0.30)
	var last_tween = next_tween.chain()
	last_tween.tween_property(_ui_text, "scale", Vector2(1, 1), 0.15) \
 		.set_trans(Tween.TRANS_CUBIC) \
 		.set_ease(Tween.EASE_OUT)
	last_tween.tween_property(_ui_text, "rotation_degrees", 0, 0.15) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)


func _get_text_center() -> Vector2:
	var bid_font: Font = _ui_text.get_theme_font("font")
	var font_size = _ui_text.get_theme_font_size("font_size")
	var text_size = bid_font.get_string_size(_ui_text.text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
	return Vector2(_ui_text.size.x - text_size.x / 2, text_size.y / 2)


func set_active_style():
	_ui_text.add_theme_color_override("font_color", ACTIVE_COLOR)
	_ui_text.add_theme_color_override("font_outline_color", ACTIVE_OUTLINE_COLOR)
	_ui_progress.add_theme_stylebox_override("fill", accent_style)


func set_inactive_style():
	_ui_text.remove_theme_color_override("font_color")
	_ui_text.remove_theme_color_override("font_outline_color")
	_ui_progress.remove_theme_stylebox_override("fill")
