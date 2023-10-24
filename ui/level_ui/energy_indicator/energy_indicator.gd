class_name EnergyIndicator extends HBoxContainer

var energy_scene = preload("res://ui/level_ui/energy_indicator/energy.tscn")
const ENERGY_PER_INDICATOR = Courier.ENERGY_PER_SPRINT
var current_energy = 0


func _init():
	Game.energy_reserve_updated.connect( _on_energy_reserve_updated)
	Game.energy_updated.connect(_on_energy_update)


func _on_energy_reserve_updated(energy_reserve):
	# Добавляем количество молний в индикаторе
	var needed_energy = energy_reserve / ENERGY_PER_INDICATOR
	var existing_energy = get_child_count()
	while existing_energy < needed_energy:
		var energy_node = energy_scene.instantiate()
		add_child(energy_node)
		existing_energy += 1
	# Удаляем ненужное количество молний в индикаторе
	while existing_energy > needed_energy:
		var energy_node = get_child(0)
		remove_child(energy_node)
		existing_energy -= 1
	var energy_limit = 0
	for energy_item  in get_children():
		energy_item.min_value = energy_limit + 1
		energy_limit += ENERGY_PER_INDICATOR
		energy_item.max_value = energy_limit
	_value_update()


func _value_update():
	for energy_item in get_children():
		energy_item.value = current_energy


func _on_energy_update(energy, _old_value):
	if current_energy != energy:
		current_energy = energy
		_value_update()
	
