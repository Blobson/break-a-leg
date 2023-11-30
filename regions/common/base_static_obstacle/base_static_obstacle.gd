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


func _on_body_entered(body: Node):
	if not body.has_method("take_damage") or state != ObstacleState.IDLE:
		return

	state = ObstacleState.ACTIVATED    # смена state на активированную

	# Если препятствие может поворачиваться, то используется _rotate_to_target()
	if flippable == true:
		_rotate_to_target(body)

	_on_damage_apply(body)
	
	if $AnimationPlayer.has_animation("activate") and state == ObstacleState.IDLE:
		$AnimationPlayer.play("activate")  # анимация активации
		$AnimationPlayer.animation_finished.connect(func(_a): _on_damage_done())
	else:
		_on_damage_done()


func _on_damage_apply(body: Node):
	body.take_damage(damage, self)


func _on_damage_done():
	if reusable:
		state = ObstacleState.IDLE
		if $AnimationPlayer.has_animation("idle"):
			$AnimationPlayer.play("idle")


func _rotate_to_target(body):
	# если позиция объекта правее чем позиция игрока, то поворачиваем модель объекта слева-направо
	if body.global_position.x > global_position.x:
		$Sprite2D.flip_h = true
