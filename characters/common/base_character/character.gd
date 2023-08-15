extends CharacterBody2D

@export var move_speed: int = 500
@export var health: int = 30 :
	set(value):
		if health != value:
			var old_value: int = health
			health = value
			Game.health_updated.emit(health, old_value)

var input = Vector2.ZERO

#Получение урона
func take_damage(damage):
	if health > 0:
		health -= damage
		if health <= 0:
			parachute_jump()

func _physics_process(delta):
	input.x = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	input.y = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	velocity = input * move_speed
	move_and_slide()

#Прыжок с парашютом по окончании уровня и если health = 0
func parachute_jump():
	pass
