class_name TaskAddress

var region: Region
var street: String
var building: String


func _to_string():
	return "%s, %s %s" % [ region, building, street ]


static func generate(rnd: RandomNumberGenerator, player_expirience: int):
	var address = TaskAddress.new()
	address.region = Region.generate(rnd, player_expirience)
	address.street = address.region.generate_street(rnd)
	address.building = str(rnd.randi_range(1, 300))
	return address
