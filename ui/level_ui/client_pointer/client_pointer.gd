extends Sprite2D

## Расстояние до клиента в экранах для начала показа указателя
const SCREENS_TO_CLIENT = 2.5
const INITIAL_SCALE = 4
const INITIAL_CENTER_OFFSET = -200
const CURVE_SMOOTHNESS = 100
const APPEAR_TIMEOUT = 3

enum PointerFrames {LEFT, TOP_LEFT, TOP, TOP_RIGHT, RIGHT}

## Список ближайших клиентов
var clients: Array[Vector2i] = []

## Половина ширины спрайта указателя
var half_size: Vector2i

## Кривая для появления указателя
var curve: Curve2D = Curve2D.new()

## Время до начала слежения
var start_follow_after = 0


func _init():
	Game.new_client.connect(_on_new_client)


func _ready():
	visible = false
	half_size = Vector2i(
		ceil(texture.get_width() / (hframes * 2.0) * scale.x), 
		ceil(texture.get_height() / (vframes * 2.0) * scale.y)
	)
	var center = Utils.get_camera_rect().get_center()
	curve.add_point(Vector2(center.x, center.y + INITIAL_CENTER_OFFSET), Vector2.ZERO, Vector2(0, -CURVE_SMOOTHNESS))
	curve.add_point(Vector2.ZERO)


func _on_new_client(pos: Vector2i):
	clients.append(pos)


func _get_next_client():
	var next_client = null
	var center = Utils.get_view_center()
	while not next_client and clients.size():
		if clients[0].y <= center.y:
			return clients[0]
		visible = false
		clients.pop_front()
	return null


func _process(delta: float):
	var client_pos = _get_next_client()
	if not client_pos:
		return
		
	client_pos = Utils.to_camera_coords(client_pos)

	_follow_client(client_pos, delta)


func _get_target_position(client_pos: Vector2i, camera_rect: Rect2i) -> Vector2i:
	return Vector2i(
		clamp(client_pos.x, camera_rect.position.x, camera_rect.end.x),
		clamp(client_pos.y, camera_rect.position.y, camera_rect.end.y)
	)


func _get_target_frame(client_pos: Vector2i, target_pos: Vector2i) -> PointerFrames:
	if target_pos.x == client_pos.x:
		return PointerFrames.TOP
	if target_pos.y == client_pos.y:
		return PointerFrames.LEFT if client_pos.x < target_pos.x else PointerFrames.RIGHT
	return PointerFrames.TOP_LEFT if client_pos.x < target_pos.x else PointerFrames.TOP_RIGHT


func _update_curve_target(client_pos: Vector2i, target_pos: Vector2i):
	var dir = Vector2.ZERO
	if target_pos.x == client_pos.x:
		dir = Vector2.DOWN
	elif target_pos.y == client_pos.y:
		dir = Vector2.RIGHT if client_pos.x < target_pos.x else Vector2.LEFT
	else:
		dir = (Vector2(1, 1) if client_pos.x < target_pos.x else Vector2(-1, 1)).normalized()
	curve.set_point_position(1, target_pos)
	curve.set_point_in(1, dir * CURVE_SMOOTHNESS)


func _follow_client(client_pos: Vector2i, delta: float):
	var camera_rect = Utils.get_camera_rect()
	
	# Расстояние до клиента должно быть не больше SCREENS_TO_CLIENT экранов
	if camera_rect.position.y - client_pos.y > camera_rect.size.y * SCREENS_TO_CLIENT:
		return
		
	if camera_rect.has_point(client_pos):
		visible = false
		return
	
	if not visible:
		start_follow_after = APPEAR_TIMEOUT
		_update_curve_target(client_pos, _get_target_position(client_pos, camera_rect))
		frame = PointerFrames.TOP
		position = curve.sample_baked(0)
		rotation = 0
		visible = true
		$Trail.emitting = true
		var tween = create_tween()
		tween.tween_property(self, "scale", scale, APPEAR_TIMEOUT).from(scale * INITIAL_SCALE)
		tween.parallel().tween_property($Trail.process_material, "scale_min", $Trail.process_material.scale_min, APPEAR_TIMEOUT).from($Trail.process_material.scale_min * INITIAL_SCALE)
		tween.parallel().tween_property($Trail.process_material, "scale_max", $Trail.process_material.scale_max, APPEAR_TIMEOUT).from($Trail.process_material.scale_max * INITIAL_SCALE)
		return

	start_follow_after -= delta
	if start_follow_after > 0:
		_update_curve_target(client_pos, _get_target_position(client_pos, camera_rect))
		var tx = curve.sample_baked_with_rotation(curve.get_baked_length() * ((APPEAR_TIMEOUT - start_follow_after) / APPEAR_TIMEOUT))
		position = tx.get_origin()
		rotation = tx.get_rotation()
	else:
		$Trail.emitting = false
		position = _get_target_position(client_pos, camera_rect)
		rotation = 0
		frame = _get_target_frame(client_pos, position)
