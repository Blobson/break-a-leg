extends CharacterBody2D

@export var move_speed: int = 200
@export var animation_time: float = 0.3
@export var health: int = 30 :
	set(value):
		if health != value:
			var old_value: int = health
			health = value
			Game.health_updated.emit(health, old_value)
@onready var animation = $AnimationPlayer
var level_width
var level_tile_size


## Получение урона
func take_damage(damage):
	if health > 0:
		health -= damage
		if health <= 0:
			parachute_jump()


func _init():
	Game.level_start.connect(_on_level_start)
	

func _ready():
	velocity.y = -move_speed
	velocity.x = 0
	SwipeDetector.swiped.connect(_on_swipe)


## Ширина уровня и размер тайла
func _on_level_start(width, tile_size):
	level_width = width
	level_tile_size = tile_size


## Движение
func _physics_process(delta):
	move_and_slide()


## Обработка input
func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		move(Vector2.UP)
	elif event.is_action_pressed("ui_left"):
		move(Vector2.LEFT)
	elif event.is_action_pressed("ui_right"):
		move(Vector2.RIGHT)


func _on_swipe(direction: Vector2):
	if direction in [Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
		move(direction)


## Обработка свайпов (tweens & animations)
func move(direction: Vector2):
	var tween = get_tree().create_tween()
	if direction == Vector2.UP:
		tween.tween_property(self, "position:y", position.y - level_tile_size.y * 2, animation_time)
		animation.play("jump_up")	
	elif direction == Vector2.LEFT:
		var target_position = position.x - level_tile_size.x
		if target_position > (-level_width / 2) + (level_tile_size.x / 3):
			tween.tween_property(self, "position:x", target_position, animation_time)
			animation.play("left")
	elif direction == Vector2.RIGHT:
		var target_position = position.x + level_tile_size.x
		if target_position < (level_width / 2) - (level_tile_size.x / 3):
			tween.tween_property(self, "position:x", target_position, animation_time)
			animation.play("right")


## Прыжок с парашютом по окончании уровня и если health = 0
func parachute_jump():
	pass
