class_name Heart extends MarginContainer

enum State {FULL, BROKEN, EMPTY}
var state := State.FULL:
	set(new_state):
		if new_state == State.EMPTY:
			queue_free()
		elif new_state == State.FULL:
			$TextureRect.texture.set_current_frame(0)
		elif new_state == State.BROKEN:
			$TextureRect.texture.set_current_frame(1)
		state = new_state
func _ready():
	$TextureRect.texture = $TextureRect.texture.duplicate(true)
