extends Label
var max_packages
var delivered_packages = 0

func _ready():
	Game.package_max_count.connect(on_task_accepted)
	Game.delivery.connect(on_package_delivered)
	
func on_task_accepted(max_count):
	max_packages = max_count
	self.text = str(delivered_packages, "/", max_packages)
	
func on_package_delivered(complete: bool):
	delivered_packages += 1
	self.text = str(delivered_packages, "/", max_packages)
