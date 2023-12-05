extends AnimatedSprite2D

const PLEASED_ANIMATION = "with_package"
const UPSET_ANIMATION = "upset"


func _ready():
	$DeliverArea.body_entered.connect(_on_deliver_area_entered)
	$Deadline.body_entered.connect(_on_deadline_passed)


func _on_deliver_area_entered(body):
	if body is Courier or body.get_parent() is Courier:
		Game.delivery.emit(true)
		$Deadline.set_monitoring(false)
		if sprite_frames.has_animation(PLEASED_ANIMATION):
			animation = PLEASED_ANIMATION


func _on_deadline_passed(body):
	if body is Courier or body.get_parent() is Courier:
		Game.delivery.emit(false)
		if sprite_frames.has_animation(UPSET_ANIMATION):
			animation = UPSET_ANIMATION
