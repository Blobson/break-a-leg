extends Node

signal swiped(direction: Vector2)

const MIN_SWIPE_PIXELS = 35
const MAX_DIAGONAL_SLOPE = 1.3
const SWIPE_TIMEOUT = 0.25

var swipe_start_position: Vector2 = Vector2.ZERO


func _unhandled_input(event):
	if event is InputEventScreenTouch and event.pressed:
		_start_detection(event)
	elif event is InputEventScreenTouch and not event.pressed:
		_detect_swipe(event)
		swipe_start_position = Vector2.ZERO
	elif event is InputEventScreenDrag:
		if _detect_swipe(event):
			swipe_start_position = Vector2.ZERO


func _start_detection(event: InputEvent):
	swipe_start_position = event.position


func _detect_swipe(event: InputEvent) -> bool:
	if swipe_start_position == Vector2.ZERO:
		return false
	var direction = event.position - swipe_start_position
	if direction.length() < MIN_SWIPE_PIXELS:
		return false
	direction = direction.normalized()
	var dx = abs(direction.x)
	var dy = abs(direction.y)
	if dx + dy >= MAX_DIAGONAL_SLOPE:
		return false
	if dx > dy:
		if direction.x > 0:
			swiped.emit(Vector2.RIGHT)
		else:
			swiped.emit(Vector2.LEFT)
	else:
		if direction.y < 0:
			swiped.emit(Vector2.UP)
		else:
			swiped.emit(Vector2.DOWN)
	return true
