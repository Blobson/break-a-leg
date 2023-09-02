extends Node

signal coins_updated(from, to)
signal rating_updated(new_rating)
signal health_updated(from, to)
signal level_start(width, tile_size)

## Текущий район
var region: Node2D

## Текущий уровень
var level: Node2D

## Ссылка на игрока
#func get_character() -> Character: 
#	return Game.level.get_node("character") as Character


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

