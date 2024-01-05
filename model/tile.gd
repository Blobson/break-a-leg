class_name Tile

enum Layer {WALLS, DECOR, WINDOWS, OBSTACLES}


var atlas_id: int
var scene_id: int
var coords: Vector2i = Vector2i.ZERO
var is_obstacle_allowed: bool = true
