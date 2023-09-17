extends HBoxContainer

@export var tween_duration: float = 4.

func _ready():
	Game.coins_updated.connect(_on_coins_updated)
	$Label.text = str(Game.coins)


func _on_coins_updated(old: int, new: int):
	var coin_tween = create_tween() \
	.set_trans(Tween.TRANS_QUAD) \
	.set_ease(Tween.EASE_IN)
	coin_tween.tween_method(animate_counter, old, new, tween_duration)


func animate_counter(coin_value: int):
	$Label.text = str(coin_value)
