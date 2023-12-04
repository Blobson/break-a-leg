class_name BaseStaticObstacle extends Node2D

@export var damage: int = 5
@export var flippable: bool = false
@export var reusable: bool = true

@onready var player = $AnimationPlayer
@onready var sprite = $Sprite2D

enum ObstacleState {IDLE, ACTIVATED}
var state: ObstacleState = ObstacleState.IDLE


func _ready():
	if $AnimationPlayer.has_animation("idle"):
		$AnimationPlayer.play("idle")
	$Area2D.body_entered.connect(_on_body_entered)


func get_damage_effect() -> DamageEffect:
	return null


func _on_body_entered(body: Node):
	if state != ObstacleState.IDLE:
		return
	
	var courier = body if body is Courier else body.get_parent()
	if not courier is Courier:
		return
	
	# смена state на активированную
	state = ObstacleState.ACTIVATED
	
	# Если препятствие может поворачиваться, то используется _rotate_to_target()
	if flippable == true:
		_rotate_to_target(courier)
	
	_on_damage_apply(courier)


func _on_damage_apply(courier: Courier):
	courier.take_damage(damage, get_damage_effect())
	
	if player.has_animation("activate"):
		player.play("activate")  # анимация активации
		player.animation_finished.connect(func(a): if a == "activate": _on_damage_done(), CONNECT_ONE_SHOT)
	else:
		_on_damage_done()


func _on_damage_done():
	if reusable:
		state = ObstacleState.IDLE
		if player.has_animation("idle"):
			player.play("idle")


func _rotate_to_target(body):
	# если позиция объекта правее чем позиция игрока, то поворачиваем модель объекта слева-направо
	sprite.flip_h = body.global_position.x > global_position.x
