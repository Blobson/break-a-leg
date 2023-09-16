extends Node


class Region:
	var dir: String
	
	func _to_string():
		return dir.to_pascal_case()


class RegionStreet:
	var region: Region
	var street: String


class TaskAddress extends RegionStreet:
	var building: String

	func _to_string():
		return "%s, %s %s" % [ region, building, street ]


class Task:
	var address: TaskAddress
	var packages: int
	var difficulty: int
	
	func _to_string():
		return "%s (packages: %d, difficulty: %d)" % [ address, packages, difficulty ]


const regions_dir = "res://regions"
const streets_file = "streets.txt"
var streets: Array[RegionStreet] = []


func _init():
	_load_streets()


func generate_task_list(player_expirience: int) -> Array[Task]:
	var rnd = RandomNumberGenerator.new()
	var tasks: Array[Task] = []
	for i in randi_range(5, 8):
		tasks.append(_generate_task(rnd, player_expirience))
	return tasks


func _generate_task(rnd: RandomNumberGenerator, player_expirience: int) -> Task:
	var task = Task.new()
	task.address = _generate_task_address(rnd)
	task.difficulty = maxi(1, rnd.randi_range(player_expirience - 1, player_expirience + 2))
	task.packages = rnd.randi_range(1, 5)
	return task


func _generate_task_address(rnd: RandomNumberGenerator) -> TaskAddress:
	var address = TaskAddress.new()
	var rs = _select_random_street(rnd)
	address.region = rs.region
	address.street = rs.street
	address.building = _generate_building(rnd)
	return address


func _select_random_street(rnd: RandomNumberGenerator) -> RegionStreet:
	return streets[rnd.randi() % streets.size()]


func _generate_building(rnd: RandomNumberGenerator) -> String:
	return "%d" % rnd.randi_range(1, 300)


func _load_streets():
	var dir = DirAccess.open(regions_dir)
	assert(dir, "Regions directory '%s' does not exist" % regions_dir)
	var regions = dir.get_directories()
	for region_dir in regions:
		var streets_file_path = "%s/%s/%s" % [regions_dir, region_dir, streets_file]
		if not FileAccess.file_exists(streets_file_path):
			continue
		var region = Region.new()
		region.dir = region_dir
		var street_file = FileAccess.open(streets_file_path, FileAccess.READ)
		while not street_file.eof_reached():
			var street = street_file.get_line()
			if not street.is_empty():
				var rs = RegionStreet.new()
				rs.region = region
				rs.street = street
				streets.append(rs)
