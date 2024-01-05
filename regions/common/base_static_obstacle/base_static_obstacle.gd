class_name BaseStaticObstacle extends Node2D

@export var damage: int = 5
@export var flippable: bool = false
@export var reusable: bool = true
@export var can_be_jumped_over: bool = true

@onready var player = $AnimationPlayer
@onready var sprite = $Sprite2D

var jumping_courier: Courier = null


func _ready():
	if $AnimationPlayer.has_animation("idle"):
		$AnimationPlayer.play("idle")
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)


func get_damage_effect() -> DamageEffect:
	return null


func _on_body_entered(body: Node):
	var courier = body if body is Courier else body.get_parent()
	if not courier is Courier:
		return
		
	if can_be_jumped_over and courier.is_jumping():
		jumping_courier = courier
		return
	
	# Если препятствие может поворачиваться, то используется _rotate_to_target()
	if flippable == true:
		_rotate_to_target(courier)
	
	_on_damage_apply(courier)


func _on_body_exited(body: Node):
	jumping_courier = null


func _process(_delta):
	if jumping_courier and not jumping_courier.is_jumping():
		_on_damage_apply(jumping_courier)
		jumping_courier = null


func _on_damage_apply(courier: Courier):
	courier.take_damage(damage, get_damage_effect())
	
	if player.has_animation("activate"):
		player.play("activate")  # анимация активации
		player.animation_finished.connect(func(a): if a == "activate": _on_damage_done(), CONNECT_ONE_SHOT)
	else:
		_on_damage_done()


func _on_damage_done():
	if reusable:
		if player.has_animation("idle"):
			player.play("idle")


func _rotate_to_target(body):
	# если позиция объекта правее чем позиция игрока, то поворачиваем модель объекта слева-направо
	sprite.flip_h = body.global_position.x > global_position.x
