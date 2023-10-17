extends MarginContainer

signal back_pressed
signal shop_pressed
signal tasks_pressed
signal rating_pressed


func _ready():
	$Buttons/BackButton.pressed.connect(func(): back_pressed.emit())
	$Buttons/ShopButton.pressed.connect(func(): shop_pressed.emit())
	$Buttons/TasksButton.pressed.connect(func(): tasks_pressed.emit())
	$Buttons/RatingButton.pressed.connect(func(): rating_pressed.emit())
