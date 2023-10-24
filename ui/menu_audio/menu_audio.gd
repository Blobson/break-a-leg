extends AudioStreamPlayer


static var menu_music_position: float = 0.0


func _ready():
	play(menu_music_position)


func _exit_tree():
	menu_music_position = get_playback_position()
