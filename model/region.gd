class_name Region

const regions_root_dir = "res://regions"
const region_info_file = "region.json"
static var regions: Array[Region]

var dir: String
var icon: Texture2D 
var streets: Array[String]


func _to_string():
	return dir.to_pascal_case()


func generate_street() -> String:
	return streets[randi() % streets.size()]


static func generate(_player_experience: int):
	if not regions:
		_load_regions()
	if regions.size():
		return regions[randi() % regions.size()]
	return null


static func _load_regions():
	var regions_dir = DirAccess.open(regions_root_dir)
	assert(regions_dir, "Regions directory '%s' does not exist" % regions_root_dir)
	regions = []
	for region_dir in regions_dir.get_directories():
		var region = Region._load_region("%s/%s" % [regions_root_dir, region_dir])
		if region:
			regions.append(region)


static func _load_region(region_dir: String):
	var region_file_path = "%s/%s" % [region_dir, region_info_file]
	if not FileAccess.file_exists(region_file_path):
		return null
	var region_file = FileAccess.open(region_file_path, FileAccess.READ)
	var region_json = region_file.get_as_text()
	region_file.close()
	var json = JSON.new()
	var result = json.parse(region_json)
	if result != OK:
		print("JSON parse ERROR[line %d]: %s" % [json.get_error_line(), json.get_error_message()])
		return null
	var region = Region.new()
	region.dir = region_dir
	var icon_path = "%s/%s" % [region_dir, json.data.icon]
	region.icon = load(icon_path)
	if not region.icon:
		print("Error loading region icon from %s" % [icon_path])
		return null
	region.streets.assign(json.data.streets.duplicate())
	return region
