extends Node

signal coins_updated(from: int, to: int)
signal rating_updated(new_rating: int)
signal health_updated(from: int, to: int)
signal level_start(width: int, tile_size: Vector2i)
signal score_updated(from: int, to: int)

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

## Очки
var score: int = 0 :
	set(value):
		if value < 0:
			value = 0
		if score != value:
			var old = score
			score = value
			score_updated.emit(old, score)


## Монетки 
var coins: int = 0 :
	set(value):
		if coins != value:
			var old = coins
			coins = value
			coins_updated.emit(old, coins)

func _ready():
	level_start.connect(_on_level_start)
	

func _on_level_start():
	score = 0

## Выход из игры
func quit():
	get_tree().quit()

