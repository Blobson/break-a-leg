class_name Heart extends TextureRect

var texture_heart
enum State {FULL, BROKEN, EMPTY}
var state := State.FULL:
	set(new_state):
		if state != new_state:
			_tween(new_state, state)
			state = new_state


func _ready():
	texture = texture.duplicate(true)
	texture_heart = texture
	
func _tween(new_state, state):
	var tween = create_tween()
	if new_state == State.BROKEN and state == State.FULL:
		tween.tween_property(texture_heart, "current_frame", 4, 1).from(0)
	elif new_state == State.EMPTY and state == State.BROKEN:
		tween.tween_property(texture_heart, "current_frame", 8, 1).from(4)
		tween.finished.connect(_tween_finished)
	elif new_state == State.EMPTY and state == State.FULL:
		tween.tween_property(texture_heart, "current_frame", 13, 1).from(9)
		tween.finished.connect(_tween_finished)
	elif new_state == State.FULL:
		texture.set_current_frame(0)
	elif new_state == State.FULL:
		texture_heart.current_frame = 0
		
func _tween_finished():
	get_parent().remove_child(self)
	queue_free()
