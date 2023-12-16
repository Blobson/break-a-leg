extends AnimatedSprite2D

const PLEASED_ANIMATION = "with_package"
const UPSET_ANIMATION = "upset"
const PACKAGE_FLY_SPEED = 80.0
const ANGRY_REACTIONS = ["unhappy", "angry", "swear"]
const HAPPY_REACTIONS = ["happy", "thumbs_up"]
const PACKAGE_START_OFFSET = Vector2(0, -23)

@onready var effects = $Effects
@onready var reactions = $Reactions
@onready var package = $Package


func _ready():
	$DeliverArea.body_entered.connect(_on_deliver_area_entered)
	$Deadline.body_entered.connect(_on_deadline_passed)


func _on_deliver_area_entered(body):
	if body is Courier or body.get_parent() is Courier:
		$Deadline.set_monitoring(false)
		_drop_package(to_local(body.global_position) + PACKAGE_START_OFFSET)


func _on_deadline_passed(body):
	if body is Courier or body.get_parent() is Courier:
		_on_package_undelivered(to_local(body.global_position))


func _drop_package(pos: Vector2):
	package.visible = true
	package.position = pos
	var tween = create_tween()
	tween.tween_property(package, "position", $PackageTarget.position, pos.length() / PACKAGE_FLY_SPEED).from(pos)
	tween.parallel().tween_property(package, "rotation", -TAU * 1.2 * sign(pos.x), pos.length() / PACKAGE_FLY_SPEED)
	tween.tween_property(package, "scale", Vector2.ZERO, 0.3).from(package.scale)
	tween.finished.connect(func(): _on_package_delivered(pos))


func _on_package_delivered(pos: Vector2):
	effects.play("flash")
	if randi_range(0, 2) == 0:
		_play_random_reaction(pos, HAPPY_REACTIONS)
	if sprite_frames.has_animation(PLEASED_ANIMATION):
		play(PLEASED_ANIMATION)
	Game.delivery.emit(true)


func _on_package_undelivered(pos: Vector2):
	_play_random_reaction(pos, ANGRY_REACTIONS)
	if sprite_frames.has_animation(UPSET_ANIMATION):
		play(UPSET_ANIMATION)
	Game.delivery.emit(false)


func _play_random_reaction(target: Vector2, variants: Array):
	reactions.position.x = sign(target.x) * abs(reactions.position.x)
	reactions.flip_h = target.x < 0
	reactions.play(Utils.random_choice(variants))
