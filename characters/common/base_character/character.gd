extends CharacterBody2D

@export var move_speed: int = 200
@export var jump_distance: int = 32
@export var animation_time: float = 0.3
@export var health: int = 30 :
	set(value):
		if health != value:
			var old_value: int = health
			health = value
			Game.health_updated.emit(health, old_value)

@onready var animation = $AnimationPlayer

var swipe: String = ""

#Получение урона
func take_damage(damage):
	if health > 0:
		health -= damage
		if health <= 0:
			parachute_jump()


func _ready():
	velocity.y = -move_speed
	velocity.x = 0
	
	
##Движение
func _physics_process(delta):
	move_and_slide()


##Обработка input
func _unhandled_input(event):
	if event is InputEventScreenDrag:
		if !swipe:
			if event.relative.y < -Game.swipe_speed:
				swipe = "UP"
				on_swipe(swipe)
			elif event.relative.x < -Game.swipe_speed:
				swipe = "LEFT"
				on_swipe(swipe)
			elif event.relative.x > Game.swipe_speed:
				swipe = "RIGHT"
				on_swipe(swipe)
	elif event is InputEventScreenTouch:
		if !event.pressed:
			swipe = ""


##Обработка свайпов (tweens & animations)
func on_swipe(type):
	var tween = get_tree().create_tween()
	if type == "UP":
		tween.tween_property(self, "position:y", position.y - jump_distance * 2, animation_time)
		animation.play("jump_up")
	elif type == "LEFT":
		tween.tween_property(self, "position:x", position.x - jump_distance, animation_time)
		animation.play("left")
	elif type == "RIGHT":
		tween.tween_property(self, "position:x", position.x + jump_distance, animation_time)
		animation.play("right")


##Прыжок с парашютом по окончании уровня и если health = 0
func parachute_jump():
	pass
