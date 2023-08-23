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
enum {NONE, UP, LEFT, RIGHT}   ## move direction
var swipe = NONE 


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
		move(UP)
	elif event.is_action_pressed("ui_left"):
		move(LEFT)
	elif event.is_action_pressed("ui_right"):
		move(RIGHT)	
	elif event is InputEventScreenDrag:
		if !swipe:
			if event.relative.y < -Game.swipe_speed:
				swipe = UP
				move(swipe)
			elif event.relative.x < -Game.swipe_speed:
				swipe = LEFT
				move(swipe)
			elif event.relative.x > Game.swipe_speed:
				swipe = RIGHT
				move(swipe)
	elif event is InputEventScreenTouch:
		if !event.pressed:
			swipe = NONE


## Обработка свайпов (tweens & animations)
func move(type):
	var tween = get_tree().create_tween()
	if type == UP:
		tween.tween_property(self, "position:y", position.y - level_tile_size.y * 2, animation_time)
		animation.play("jump_up")	
	elif type == LEFT:
		var target_position = position.x - level_tile_size.x
		if target_position > (-level_width / 2) + (level_tile_size.x / 3):
			tween.tween_property(self, "position:x", target_position, animation_time)
			animation.play("left")
	elif type == RIGHT:
		var target_position = position.x + level_tile_size.x
		if target_position < (level_width / 2) - (level_tile_size.x / 3):
			tween.tween_property(self, "position:x", target_position, animation_time)
			animation.play("right")


## Прыжок с парашютом по окончании уровня и если health = 0
func parachute_jump():
	pass
