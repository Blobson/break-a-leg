extends Label

const INACTIVE_COLOR = Color8(171, 194, 232, 255)
const ACTIVE_COLOR = Color8(254, 101, 0, 255)


func set_bid(bid: int):
	self.text = str(bid)


func update(bid: int):
	set_bid(bid)
	pivot_offset = _get_text_center()
	var bid_tween = create_tween()
	bid_tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	bid_tween.tween_property(self, "rotation_degrees", -10, 0.15) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_IN)
	var next_tween = bid_tween.chain()
	next_tween.tween_property(self, "rotation_degrees", 10, 0.30)
	var last_tween = next_tween.chain()
	last_tween.tween_property(self, "scale", Vector2(1, 1), 0.15) \
 		.set_trans(Tween.TRANS_CUBIC) \
 		.set_ease(Tween.EASE_OUT)
	last_tween.tween_property(self, "rotation_degrees", 0, 0.15) \
		.set_trans(Tween.TRANS_CUBIC) \
		.set_ease(Tween.EASE_OUT)


func _get_text_center() -> Vector2:
	var bid_font: Font = get_theme_font("font")
	var font_size = get_theme_font_size("font_size")
	var text_size = bid_font.get_string_size(self.text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
	return Vector2(size.x - text_size.x / 2, text_size.y / 2)


func set_active_style():
	add_theme_color_override("font_color", ACTIVE_COLOR)


func set_inactive_style():
	add_theme_color_override("font_color", INACTIVE_COLOR)
