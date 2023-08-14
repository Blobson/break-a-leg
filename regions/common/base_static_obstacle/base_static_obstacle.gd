class_name BaseStaticObstacle extends Node2D

@export var damage: int = 5

func _ready():
	if $AnimationPlayer.has_animation("idle"):
		$AnimationPlayer.play("idle")
	$Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node):
	if $AnimationPlayer.has_animation("activate"):
		$AnimationPlayer.play("activate")  # анимация активации
	if body.has_method("take_damage"):
		body.take_damage(damage)
