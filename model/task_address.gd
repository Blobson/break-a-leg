class_name TaskAddress

var region: Region
var street: String
var building: String


func _to_string():
	return "%s, %s %s" % [ region, building, street ]


static func generate(player_experience: int):
	var address = TaskAddress.new()
	address.region = Region.random(player_experience)
	address.street = address.region.random_street()
	address.building = str(randi_range(1, 300))
	return address
