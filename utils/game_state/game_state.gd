extends Node

signal coins_updated(from, to)
signal rating_updated(new_rating)


## Текущий район
var region: Node2D


## Рейтинг игрока
var rating: int = 0 :
	set(value):
		if rating != value:
			rating = value
			rating_updated.emit(rating)


## Монетки 
var coins: int = 0 :
	set(value):
		if coins != value:
			var old = coins
			coins = value
			coins_updated.emit(old, coins)


## Выход из игры
func quit():
	get_tree().quit()

