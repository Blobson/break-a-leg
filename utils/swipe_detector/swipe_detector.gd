extends Node

signal swiped(direction: Vector2)

const MIN_SWIPE_PIXELS = 30
const MAX_DIAGONAL_SLOPE = 1.3
const SWIPE_TIMEOUT = 0.25

var swipe_start_position: Vector2 = Vector2.ZERO
var timer: Timer = Timer.new()

func _init():
	timer.one_shot = true
	timer.wait_time = SWIPE_TIMEOUT

func _ready():
	add_child(timer)
	timer.timeout.connect(_on_detection_timeout)


func _unhandled_input(event):
	if not event is InputEventScreenTouch:
		return
	if event.pressed:
		_start_detection(event.position)
	elif not timer.is_stopped():
		_stop_detection(event.position)


func _start_detection(position: Vector2):
	swipe_start_position = position
	timer.start()


func _stop_detection(position: Vector2):
	timer.stop()
	if swipe_start_position == Vector2.ZERO:
		return
	var direction = position - swipe_start_position
	if direction.length() < MIN_SWIPE_PIXELS:
		return
	direction = direction.normalized()
	var dx = abs(direction.x)
	var dy = abs(direction.y)
	if dx + dy >= MAX_DIAGONAL_SLOPE:
		return
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


func _on_detection_timeout():
	swipe_start_position = Vector2.ZERO
