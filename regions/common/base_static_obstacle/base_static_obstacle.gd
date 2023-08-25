class_name BaseStaticObstacle extends Node2D

@export var damage: int = 5
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
	var obstacle_position = $'.'.global_transform.origin.x
	var courier_position_x = body.get_global_position().x
	if courier_position_x > obstacle_position:
		$Sprite2D.flip_h = true
