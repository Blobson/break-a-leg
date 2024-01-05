class_name Grandma extends BaseStaticObstacle


func _ready():
	super()
	$Sprite2D.flip_h = randi_range(0, 1)
	$ActivateTimer.start(randi_range(2, 4))
	$ActivateTimer.timeout.connect(_on_activate_timer_timeout)
	$DustArea.body_entered.connect(_on_dust_area_body_entered)
	
	# Всегда нужно удалять тайл окна, поверх которого устанавливается бабка
	var parent = get_parent() as TileMap
	if parent:
		var cell = parent.local_to_map(position)
		parent.erase_cell(Tile.Layer.WINDOWS, cell)
		# Без notify_runtime_tile_data_update сцена окна не удаляется из кеша TileMap'a
		parent.call_deferred("notify_runtime_tile_data_update", Tile.Layer.WINDOWS)


func get_damage_effect() -> DamageEffect:
	return CarpetEntangled.new()


func _on_activate_timer_timeout():
	if player.current_animation != "idle":
		return 
	player.play('grandma_is_shaking_the_rug')
	$SoundFX1.set_pitch_scale(randf_range(0.9, 1.2))
	$SoundFX1.play()


func _on_body_entered(body: Node):
	super(body)
	$DustArea.collision_mask = 0
	player.play("grandma_is_swearing")


func _on_dust_area_body_entered(body: Node):
	var courier = body if body is Courier else body.get_parent()
	if not courier is Courier:
		return
	courier.take_damage(damage, Dusty.new())
