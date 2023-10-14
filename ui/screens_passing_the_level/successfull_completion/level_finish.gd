@tool extends PanelContainer


const MAX_PACKAGE = 5
const TWEEN_DURATION: float = 0.5 

@export var success: bool = true

@onready var active_screen = $Success if success else $Failure
@onready var phone_button = $Success/Phone/TextureButton if success else $Failure/Phone/TextureButton
@onready var phone_sprite = $Success/Phone if success else $Failure/Phone
@onready var stars_array = $Success/Board/Stars.get_children()
@onready var empty_stars_array = $Success/Board/EmtyStars.get_children() if success else $Failure/Board/EmtyStars.get_children()
@onready var coin_counter = $Success/Board/CoinCounter if success else $Failure/Board/CoinCounter
@onready var coin_label = $Success/Board/CoinCounter/Label if success else $Failure/Board/CoinCounter/Label
@onready var rating_label = $Success/Board/Raiting/Label if success else $Failure/Board/Raiting/Label
@onready var packages_counter = $Success/Board/PackageCounter if success else $Failure/Board/PackageCounter
@onready var package_label = $Success/Board/PackageCounter/Label if success else $Failure/Board/PackageCounter/Label


## Количество звёзд
@export var stars: int = 5:
	set(value):
		if stars != value:
			var old_value: int = stars
			stars = value
			Game.stars_updated.emit(stars, old_value)


func _ready():
	$Success.visible = success
	$Failure.visible = !success
	phone_button.connect("pressed", _on_phone_pressed)
	Game.stars_updated.connect(_on_stars_updated)
	Game.coins_updated.connect(_on_coins_updated)
	Game.rating_updated.connect(_on_rating_updated)
	Game.packages_updated.connect(_on_packages_updated)
	## TODO: привязать сигнал по изменению success


func _on_phone_pressed():
	var tween = create_tween()
	tween.tween_property(phone_sprite, "scale", Vector2(70, 70), 0.5)
	tween.finished.connect(_show_menu)


func _show_menu():
	get_tree().change_scene_to_file("res://ui/menu/phone_menu/phone_menu.tscn")


func _on_stars_updated(stars, old_value):
	if success:
		var tween = create_tween() \
		.set_trans(Tween.TRANS_BOUNCE) \
		.set_ease(Tween.EASE_OUT)
		_set_empty_stars_visibility()
		for star in range(stars):
			tween.tween_property(stars_array[star], "position", Vector2(stars_array[star].position.x, stars_array[star].position.y + 250), TWEEN_DURATION).from(stars_array[star].position)
			stars_array[star].set_visible(true)	
	else:
		_set_empty_stars_visibility()
	


func _set_empty_stars_visibility():
	var tween = create_tween()
	for empty_star in empty_stars_array:
		empty_star.set_visible(true)
		tween.tween_method(empty_star.set_modulate, Color(1, 1, 1, 0), Color(1, 1, 1, 1), TWEEN_DURATION)
		


func _on_coins_updated(old, coins):
	coin_label.text = "%d" % [coins]
	var tween = create_tween()
	tween.tween_property(coin_counter, "position", Vector2(coin_counter.position.x, coin_counter.position.y), TWEEN_DURATION).from(Vector2(coin_counter.position.x - 300, coin_counter.position.y))


func _on_rating_updated(rating):
	rating_label.text = "%.1f" % [rating]
	var tween = create_tween()
	tween.tween_property(rating_label, "position", Vector2(rating_label.position.x, rating_label.position.y), TWEEN_DURATION).from(Vector2(rating_label.position.x, rating_label.position.y + 300))


func _on_packages_updated(packages):
	package_label.text = "%d/%d" % [packages, MAX_PACKAGE]
	var tween = create_tween()
	tween.tween_property(packages_counter, "position", Vector2(packages_counter.position.x, packages_counter.position.y), TWEEN_DURATION).from(Vector2(packages_counter.position.x - 300, packages_counter.position.y))

