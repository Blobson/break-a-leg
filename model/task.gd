class_name Task

var address: TaskAddress
var packages: int
var difficulty: int
var bid: int


func _to_string():
	return "%s (packages: %d, difficulty: %d)" % [ address, packages, difficulty ]


static func generate(rnd: RandomNumberGenerator, player_expirience: int):
	var task = Task.new()
	task.address = TaskAddress.generate(rnd, player_expirience)
	task.difficulty = maxi(1, rnd.randi_range(player_expirience - 1, player_expirience + 2))
	task.packages = maxi(1, rnd.randi_range(task.difficulty - 1, task.difficulty + 2))
	task.bid = task.difficulty * 10
	return task
