extends Sprite2D

enum PointerFrames {LEFT, TOP_LEFT, TOP, TOP_RIGHT, RIGHT}

var clients: Array[Vector2i] = []
var half_size: Vector2i


func _init():
	Game.new_client.connect(_on_new_client)


func _ready():
	visible = false
	half_size = Vector2i(
		ceil(texture.get_width() / (hframes * 2.0) * scale.x), 
		ceil(texture.get_height() / (vframes * 2.0) * scale.y)
	)


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


func _process(_delta):
	var camera_rect = Utils.get_camera_rect()

	var client_pos = _get_next_client()
	if not client_pos:
		return
	
	client_pos = Utils.to_camera_coords(client_pos)
	if camera_rect.position.y - client_pos.y > camera_rect.size.y:
		return
	
	var show_pointer = true
	if client_pos.x < camera_rect.position.x + half_size.x:
		frame = PointerFrames.TOP_LEFT
		position.x = camera_rect.position.x
	elif client_pos.x > camera_rect.end.x - half_size.x:
		frame = PointerFrames.TOP_RIGHT
		position.x = camera_rect.end.x
	else:
		frame = PointerFrames.TOP
		position.x = client_pos.x

	if client_pos.y < camera_rect.position.y:
		position.y = camera_rect.position.y
	else:
		position.y = client_pos.y
		if frame == PointerFrames.TOP_LEFT:
			frame = PointerFrames.LEFT
		elif frame == PointerFrames.TOP_RIGHT:
			frame = PointerFrames.RIGHT
		else:
			show_pointer = false
			
	if visible != show_pointer:
		if show_pointer:
			_wobble()
		visible = show_pointer


func _wobble():
	var tween = create_tween()
	for _i in 2:
		tween.tween_property(self, "scale", scale * 6, 0.3)
		tween.tween_property(self, "scale", scale, 0.3)
	tween = create_tween()
	for _i in 2:
		tween.tween_property(self, "self_modulate", Color(0.7, 0.7, 0.7), 0.3)
		tween.tween_property(self, "self_modulate", Color(1, 1, 1), 0.3)
	
