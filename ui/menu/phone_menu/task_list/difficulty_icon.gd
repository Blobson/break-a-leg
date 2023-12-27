extends CenterContainer

@onready var icon: AnimatedSprite2D = $AnimatedSprite2D


func play(difficulty: String):
	var animations = []
	for anim in icon.sprite_frames.get_animation_names():
		if anim.begins_with(difficulty):
			animations.append(anim)
	if animations:
		icon.play(Utils.random_choice(animations))
