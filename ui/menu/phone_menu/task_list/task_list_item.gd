class_name TaskListItem extends PanelContainer

var task: Task = Task.generate(RandomNumberGenerator.new(), 3)
var normal_style: StyleBox = get_theme_stylebox('panel')
var hover_style: StyleBox
var address_color: Color


func _init():
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)	
	hover_style = normal_style.duplicate()
	hover_style.bg_color = normal_style.bg_color.lightened(0.3)
	

func _ready():
	$HBoxContainer/RegionIcon.texture = task.address.region.icon
	$HBoxContainer/TextBox/Address.text = "%s %s" % [ task.address.building, task.address.street ]
	$HBoxContainer/TextBox/Packages.text = "packages: %d" % [task.packages]
	$HBoxContainer/BidBox/BidText.text = str(task.bid)
	address_color = $HBoxContainer/TextBox/Address.get_theme_color("font_color")


func update_bid(bid: int):
	var bid_tween = create_tween()
	bid_tween.tween_method(_animate_bid_text, task.bid, bid, 0.5)
	var scale_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	$HBoxContainer/BidBox/BidText.pivot_offset = Vector2(25, 25)
	scale_tween.tween_property($HBoxContainer/BidBox/BidText, "scale", Vector2(1.3, 1.3), 0.4).set_ease(Tween.EASE_IN)
	scale_tween.chain().tween_property($HBoxContainer/BidBox/BidText, "scale", Vector2(1, 1), 0.4).set_ease(Tween.EASE_OUT)
	task.bid = bid


func _animate_bid_text(bid: int):
	$HBoxContainer/BidBox/BidText.text = str(bid)


func _on_focus_entered():
	add_theme_stylebox_override('panel', hover_style)
	$HBoxContainer/TextBox/Address.add_theme_color_override("font_color", normal_style.bg_color)


func _on_focus_exited():
	add_theme_stylebox_override('panel', normal_style)
	$HBoxContainer/TextBox/Address.add_theme_color_override("font_color", address_color)
