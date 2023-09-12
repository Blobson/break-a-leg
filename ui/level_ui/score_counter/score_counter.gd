extends Control

@export var tween_duration: float = 0.2

func _ready():
	Game.score_updated.connect(_on_score_updated)
	self.text = str(Game.score)


func _on_score_updated(old: int, score: int):
	var score_tween = create_tween() 
	score_tween.tween_method(animate_score, old, score, tween_duration)


func animate_score(gold_value: int):
	self.text = str(gold_value)
