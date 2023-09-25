class_name Courier extends CharacterBody2D

const ENERGY_PER_SPRINT = 100

@onready var animation = $AnimationPlayer

## Скорость движения
@export var move_speed: int = 0

## Длина прыжка в тайлах
@export var jump_length: float = 1.5


## Жизни персонажа
@export var health: int = 30 :
	set(value):
		if health != value:
			var old_value: int = health
			health = value
			Game.health_updated.emit(health, old_value)

## Максимальное количество зарядов в индикаторе энергии
@export var energy_reserve: int = 2 * ENERGY_PER_SPRINT : 
	set(value):
		if value < 0:
			value = 0
		assert(value % ENERGY_PER_SPRINT == 0, "energy_reserve always should be multiple of 10")
		if energy_reserve != value:
			var old_value = energy_reserve
			energy_reserve = value
			Game.energy_reserve_updated.emit(energy_reserve, old_value)

## Текущее количество энергии
var energy: int = energy_reserve : 
	set(value):
		if value < 0:
			value = 0
		elif value > energy_reserve:
			value = energy_reserve 
		if energy != value:
			var old_value = energy
			energy = value
			Game.energy_updated.emit(energy, old_value)

@export var energy_recovery_speed: int = 20

@export var damage_score_losing: int = 20


var level_width: int
var level_tile_size: Vector2i
var movement_tween: Tween
var next_move: Vector2 = Vector2.ZERO
var last_tile: int = 0


## Получение урона
func take_damage(damage):
	if health > 0:
		health -= damage
		Game.score -= damage_score_losing
		if health <= 0:
			parachute_jump()
			@warning_ignore("integer_division")
			Game.score -= int(Game.score / 2)


func _init():
	Game.level_start.connect(_on_level_start)	
	SwipeDetector.swiped.connect(_on_swipe)

func _ready():
	Game.health_updated.emit(health, 0)
	velocity.y = -move_speed
	velocity.x = 0
	$EnergyRecoveryTimer.timeout.connect(_on_energy_recover)

## Запуск уровня
func _on_level_start(width, tile_size):
	# Сохраняем ширину уровня и размер тайла
	level_width = width
	level_tile_size = tile_size
	Game.energy_reserve_updated.emit(energy_reserve)
	Game.energy_updated.emit(energy, energy)


## Движение
func _physics_process(_delta):
	move_and_slide()
	var new_tile = floor(-position.y / level_tile_size.y)
	if last_tile < new_tile:
		Game.score += (new_tile - last_tile)
		last_tile = new_tile


## Обработка input
func _unhandled_input(event):
	if event.is_action_pressed("ui_up"):
		move(Vector2.UP)
	elif event.is_action_pressed("ui_left"):
		move(Vector2.LEFT)
	elif event.is_action_pressed("ui_right"):
		move(Vector2.RIGHT)


## Обработка свайпов
func _on_swipe(direction: Vector2):
	if direction in [Vector2.UP, Vector2.LEFT, Vector2.RIGHT]:
		move(direction)


## Обработка движения персонажа
func move(direction: Vector2):
	if _is_moving():
		next_move = direction
	else:
		movement_tween = _start_move(direction)


func _is_moving() -> bool:
	return movement_tween and movement_tween.is_running()


func _start_move(direction: Vector2) -> Tween:
	var target_position: Vector2
	if direction == Vector2.UP and energy >= ENERGY_PER_SPRINT:
		animation.play("jump_up")
		target_position = Vector2(
			position.x, 
			position.y - level_tile_size.y * jump_length
		)
		energy -= ENERGY_PER_SPRINT
		$EnergyRecoveryTimer.start()
	elif direction == Vector2.LEFT:
		animation.play("left")
		target_position = Vector2(
			position.x - level_tile_size.x, 
			position.y - move_speed * animation.current_animation_length
		)
		@warning_ignore("integer_division")
		var min_x = (-level_width / 2) + (level_tile_size.x / 3)
		if target_position.x <= min_x: 
			return null
	elif direction == Vector2.RIGHT:
		animation.play("right")
		target_position = Vector2(
			position.x + level_tile_size.x, 
			position.y - move_speed * animation.current_animation_length
		) 
		@warning_ignore("integer_division")
		var max_x = (level_width / 2) - (level_tile_size.x / 3)
		if target_position.x >= max_x:
			return null
	else:
		return null
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, animation.current_animation_length)
	tween.finished.connect(_end_move)
	return tween


func _end_move():
	if next_move:
		move(next_move)
		next_move = Vector2.ZERO
	else:
		movement_tween = null


## Прыжок с парашютом по окончании уровня и если health = 0
func parachute_jump():
	pass


func _on_energy_recover():
	if energy < energy_reserve:
		energy = min(energy_reserve, energy + roundi(energy_recovery_speed * $EnergyRecoveryTimer.wait_time))
		if energy == energy_reserve:
			$EnergyRecoveryTimer.stop()
