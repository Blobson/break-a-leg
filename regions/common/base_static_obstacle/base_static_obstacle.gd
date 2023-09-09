class_name BaseStaticObstacle extends Node2D

@export var damage: int = 1
@export var flippable: bool = false

enum ObstacleState {IDLE, ACTIVATED}
var state: ObstacleState = ObstacleState.IDLE

func _ready():
	if $AnimationPlayer.has_animation("idle"):
		$AnimationPlayer.play("idle")
	$Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node):
	# Если препятствие может поворачиваться к игроку, то используется _deploy_to_target()
	if flippable == true and body.name == "Courier": 
		_deploy_to_target(body)
	if $AnimationPlayer.has_animation("activate") and state == ObstacleState.IDLE:
		$AnimationPlayer.play("activate")  # анимация активации
		state = ObstacleState.ACTIVATED    # смена state на активированную
	if body.has_method("take_damage"):
		body.take_damage(damage)

func _deploy_to_target(body):
	# если позиция объекта правее чем позиция игрока, то поворачиваем модель объекта слева-направо
	if body.global_position.x > global_position.x:
		$Sprite2D.flip_h = true
