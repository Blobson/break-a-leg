class_name GameCamera extends Camera2D

var width = ProjectSettings.get_setting('display/window/size/viewport_width')
var height = ProjectSettings.get_setting('display/window/size/viewport_height')


func _ready():
	get_tree().root.size_changed.connect(_set_camera_center_position)


func _set_camera_center_position():
	var current_width = get_viewport_rect().size.x
	var current_height = get_viewport_rect().size.y
	offset = Vector2((current_width / 2) - (width / 2), (current_height / 2) - (height / 2))
