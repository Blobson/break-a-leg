extends Node2D


##Возвращает ширину тайловой карты
func _ready():
	var tile_set = $Tilemap.tile_set
	var tile_size = tile_set.tile_size
	var width = $Tilemap.get_used_rect().size.x * tile_size.x
	Game.level_start.emit(width, tile_size)
