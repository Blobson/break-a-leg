class_name Region


const regions_root_dir = "res://regions"
const region_info_file = "region.json"
static var regions: Array[Region]

var dir: String
var icon: Texture2D 
var streets: Array[String] = []
var package_price: int = 1
var level_templates: Array[LevelTemplate] = []


func _to_string():
	return dir.to_pascal_case()


func random_street() -> String:
	return Utils.random_choice(streets)


func random_level_template() -> LevelTemplate:
	return Utils.random_choice(level_templates)


func init(region_dir: String, data: Dictionary) -> bool:
	dir = region_dir
	
	# загружаем иконку района
	if 'icon' not in data or not data.icon:
		push_error("Region without 'icon' is invalid")
		return false
	icon = load_resource(data.icon)
	
	# загружаем цену доставки
	if 'package_price' not in data:
		push_error("Region without 'package_price' is invalid")
		return false
	package_price = data.package_price
	
	# загружаем список улиц
	if 'streets' not in data or not data.streets:
		push_error("Region without 'streets' list is invalid")
		return false
	streets.assign(data.streets)
	
	# загружаем шаблоны уровней
	if 'level_templates' not in data or not data.level_templates:
		push_error("Region without 'level_templates' list is invalid")
		return false
	for template_data in data.level_templates:
		var template = LevelTemplate.new()
		template.init(self, template_data)
		if not template:
			return false
		level_templates.append(template)	
	
	return true


func load_resource(path: String) -> Resource:
	var res_path = "%s/%s" % [dir, path]
	var resource = load(res_path)
	if not resource:
		push_error("Error loading region resource from '%s'" % [res_path])
		return null
	return resource


static func random(_player_experience: int):
	if not regions:
		_load_regions()
	if regions.size():
		return Utils.random_choice(regions)
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
	
	# загружаем JSON c описанием района
	var region_file = FileAccess.open(region_file_path, FileAccess.READ)
	var region_json = region_file.get_as_text()
	region_file.close()
	var json = JSON.new()
	var result = json.parse(region_json)
	if result != OK:
		push_error("JSON parse ERROR['%s' line %d]: %s" % [region_file_path, json.get_error_line(), json.get_error_message()])
		return null
	
	# инициализируем район
	var region = Region.new()
	if not region.init(region_dir, json.data):
		return null
	
	return region
