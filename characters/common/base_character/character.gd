class_name Courier extends CharacterBody2D

const ENERGY_PER_SPRINT = 100
const SLOW_SPEED_MULTIPLIER = 0.25
const JETPACK_SPEED_MULTIPLIER = 1.5

signal courier_dead

@onready var sprite = $Sprite2D
@onready var player = $AnimationPlayer
@onready var animations = $Animations

## Скорость движения
@export var move_speed: int = 0

## Длина прыжка в тайлах
@export var jump_length: float = 1.5

## Длительность щита
@export var shield_length: float = 4.

## Длительность джетпака
@export var jetpack_length: float = 4.

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


var level_width: int = 7 * 32
var level_tile_size: Vector2i = Vector2i(32, 32)
var movement_tween: Tween
var next_move: Vector2 = Vector2.ZERO
var last_tile: int = 0
var ignore_input: bool = false
var invulnerability: bool = false


## Получение урона
func take_damage(damage: int, effect: DamageEffect):
	if health > 0 and !invulnerability:
		health -= damage
		Game.score -= damage_score_losing
		if not effect:
			effect = DamageEffect.new()
		effect.apply(self)
		
	if health <= 0:
		parachute_jump()
		courier_dead.emit()


func _init():
	Game.level_start.connect(_on_level_start)
	Game.shield_activate.connect(_on_shield_activate)
	Game.jetpack_activate.connect(_on_jetpack_activate)
	SwipeDetector.swiped.connect(_on_swipe)


func _ready():
	Game.health_updated.emit(health, 0)
	velocity.x = 0
	disable_slowdown()
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
	if ignore_input:
		return
	if _is_moving():
		next_move = direction
	else:
		movement_tween = _start_move(direction)


func _is_moving() -> bool:
	return movement_tween and movement_tween.is_running()


func _start_move(direction: Vector2) -> Tween:
	var target_position: Vector2
	if direction == Vector2.UP and energy >= ENERGY_PER_SPRINT:
		player.play("jump_up")
		target_position = Vector2(
			position.x, 
			position.y - level_tile_size.y * jump_length
		)
		energy -= ENERGY_PER_SPRINT
		$EnergyRecoveryTimer.start()
	elif direction == Vector2.LEFT:
		player.play("left")
		target_position = Vector2(
			position.x - level_tile_size.x, 
			position.y - move_speed * player.current_animation_length
		)
		@warning_ignore("integer_division")
		var min_x = (-level_width / 2) + (level_tile_size.x / 3)
		if target_position.x <= min_x: 
			return null
	elif direction == Vector2.RIGHT:
		player.play("right")
		target_position = Vector2(
			position.x + level_tile_size.x, 
			position.y - move_speed * player.current_animation_length
		) 
		@warning_ignore("integer_division")
		var max_x = (level_width / 2) - (level_tile_size.x / 3)
		if target_position.x >= max_x:
			return null
	else:
		return null
	var tween = get_tree().create_tween()
	tween.tween_property(self, "position", target_position, player.current_animation_length)
	tween.finished.connect(_end_move)
	return tween


func _end_move():
	if next_move:
		move(next_move)
		next_move = Vector2.ZERO
	else:
		movement_tween = null


## Jetpack ability
func _on_jetpack_activate():
	var tween = create_tween()
	invulnerability = true
	disable_collision()
	disable_input()
	set_z_index(10)
	player.play("jetpack_start")
	$JetpackTimer.start(jetpack_length)
	if(player.animation_changed):
		velocity.y = -move_speed * JETPACK_SPEED_MULTIPLIER
		tween.tween_method($Sprite2D.set_scale, Vector2(1.1, 1.1), Vector2(1.24, 1.24), 0.2)


func _on_jetpack_timer_timeout():
	var tween = create_tween()
	invulnerability = false
	enable_collision()
	enable_input()
	set_z_index(0)
	velocity.y = -move_speed
	tween.tween_method($Sprite2D.set_scale, Vector2(1.24, 1.24), Vector2(1.1, 1.1), 0.3)
	player.play("jetpack_stop")


## Shield ability
func _on_shield_activate():
	invulnerability = true
	animations.visible = true
	animations.play("shield")
	_set_shield_invisible()


func _on_shield_timeout():
	invulnerability = false
	animations.visible = false
	animations.set_modulate(Color(1, 1, 1, 1))


func _set_shield_invisible():
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_ELASTIC)
	tween.set_ease(Tween.EASE_IN)
	tween.finished.connect(_on_shield_timeout)
	tween.tween_method(animations.set_modulate, Color(1, 1, 1, 1), Color(1, 1, 1, 0), shield_length)
	

## Прыжок с парашютом по окончании уровня и если health = 0
func parachute_jump():
	pass


func _on_energy_recover():
	if energy < energy_reserve:
		energy = min(energy_reserve, energy + roundi(energy_recovery_speed * $EnergyRecoveryTimer.wait_time))
		if energy == energy_reserve:
			$EnergyRecoveryTimer.stop()


func enable_slowdown():
	velocity.y = -move_speed * SLOW_SPEED_MULTIPLIER


func recover_speed(recovery_time: float):
	var speed_tween = create_tween()
	speed_tween.tween_property(self, "velocity:y", -move_speed, recovery_time)


func disable_collision():
	$CollisionShape2D.set_disabled(true)
	$CourierFeet/CollisionShape2D.set_disabled(true)


func enable_collision():
	$CollisionShape2D.set_disabled(false)
	$CourierFeet/CollisionShape2D.set_disabled(false)


func disable_slowdown():
	velocity.y = -move_speed


func enable_input():
	ignore_input = false


func disable_input():
	ignore_input = true
	next_move = Vector2.ZERO


func is_jumping() -> bool:
	return player.is_playing() and player.current_animation == "jump_up"
