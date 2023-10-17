class_name Task

const MAX_COMPETITION = 3
const CANCEL_TIMEOUT = 12
const SELL_TIMEOUT = 7

const MIN_PACKAGES = 2
const MAX_PACKAGES = 8

## Количество монет получаемых за один доставленный пакет
const PACKAGE_VALUE = 10

const MAX_DIFFICULTY = 3
const DIFFICULTIES = {
	0: {
		"name": "too easy",
		"color": Color8(200, 200, 200, 255)
	},
	1: {
		"name": "normal",
		"color": Color8(54, 141, 0, 255)
	},
	2: {
		"name": "hard",
		"color": Color8(196, 130, 0, 255)
	},
	3: {
		"name": "impossible",
		"color": Color8(196, 53, 0, 255)
	}
}

## Адрес заказа
var address: TaskAddress

## Количество пакетов в заказе (от MIN_PACKAGES до MAX_PACKAGES)
var packages: int

## Сложность заказа (от 0 до MAX_DIFFICULTY)
var difficulty: int

## Текущая ставка по заказу
var bid: int = 0


func _to_string() -> String:
	return "%s (packages: %d, difficulty: %d, bid: %d)" % [ address, packages, difficulty, current_bid() ]


func difficulty_text() -> String:
	return DIFFICULTIES[difficulty].name


func difficulty_color() -> Color:
	return DIFFICULTIES[difficulty].color


func start_bid() -> int:
	return floor(packages * PACKAGE_VALUE * (1.0 + difficulty / (2.0 * MAX_DIFFICULTY)))


func current_bid() -> int:
	return bid if bid != 0 else start_bid()


## Рассчитываем вероятность ставки на заказ в зависимости от:
##  - конкуренции (большая конкуренция увеличивает вероятность)
##  - сложности задания (большая сложность уменьшает вероятность)
##  - текущей ставки (удаленность от максимальной ставки уменьшает вероятность)
func check_bid_probability(competition: int, max_bid: int, _max_difficulty: int) -> bool:
	var comp_delta = competition - MAX_COMPETITION # -2..0 
	# var diff_delta = difficulty - max_difficulty # -3..0
	var bid_delta = (start_bid() - current_bid()) + (max_bid - current_bid())
	var probability = 10 + max(0, bid_delta + comp_delta + difficulty)
	return randi_range(1, probability) == 1


## Последняя ставка выигрывает по истечении SELL_TIMEOUT
func check_sell_condition(last_bid_at: float) -> bool:
	var now = Time.get_unix_time_from_system()
	return bid != 0 and now - last_bid_at >= SELL_TIMEOUT


## У заказа есть шанс быть отменённым, если на заказ длительное время нет ставок
func check_cancel_probability(last_bid_at: float) -> bool:
	var now = Time.get_unix_time_from_system()
	return last_bid_at - now >= CANCEL_TIMEOUT \
			and randi_range(1, 3) == 1


static func generate(player_experience: int) -> Task:
	var task = Task.new()
	task.address = TaskAddress.generate(player_experience)
	task.difficulty = randi_range(0, MAX_DIFFICULTY)
	task.packages = MIN_PACKAGES + 0.5 * (MAX_PACKAGES - MIN_PACKAGES) * (task.difficulty+1.0) / (MAX_DIFFICULTY+1.0) + randi_range(0, 1)
	return task
