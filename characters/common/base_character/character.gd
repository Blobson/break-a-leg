extends CharacterBody2D


@export var health: int = 30 :
	set(value):
		if health != value:
			var old_value: int = health
			health = value
			Game.health_updated.emit(health, old_value)


#Получение урона
func take_damage(damage):
	if health > 0:
		health -= damage
		if health <= 0:
			parachute_jump()


#Прыжок с парашютом по окончании уровня и если health = 0
func parachute_jump():
	pass
