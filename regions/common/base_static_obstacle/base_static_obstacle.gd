class_name BaseStaticObstacle extends Node2D

@export var damage: int = 5
@export var flippable: bool = false
@export var reusable: bool = true

enum ObstacleState {IDLE, ACTIVATED}
var state: ObstacleState = ObstacleState.IDLE


func _ready():
	if $AnimationPlayer.has_animation("idle"):
		$AnimationPlayer.play("idle")
	$Area2D.body_entered.connect(_on_body_entered)


func get_damage_effect() -> DamageEffect:
	return null


func _on_body_entered(body: Node):
	if not is_instance_of(body, Courier) or state != ObstacleState.IDLE:
		return
	
	state = ObstacleState.ACTIVATED    # смена state на активированную
	
	# Если препятствие может поворачиваться, то используется _rotate_to_target()
	if flippable == true:
		_rotate_to_target(body)
	
	_on_damage_apply(body)


func _on_damage_apply(body: Node):
	if body.has_method("take_damage"):
		body.take_damage(damage, get_damage_effect())
	
	if $AnimationPlayer.has_animation("activate"):
		$AnimationPlayer.play("activate")  # анимация активации
		$AnimationPlayer.animation_finished.connect(func(a): if a == "activate": _on_damage_done(), CONNECT_ONE_SHOT)
	else:
		_on_damage_done()


func _on_damage_done():
	if reusable:
		state = ObstacleState.IDLE
		if $AnimationPlayer.has_animation("idle"):
			$AnimationPlayer.play("idle")


func _rotate_to_target(body):
	# если позиция объекта правее чем позиция игрока, то поворачиваем модель объекта слева-направо
	$Sprite2D.flip_h = body.global_position.x > global_position.x
	
