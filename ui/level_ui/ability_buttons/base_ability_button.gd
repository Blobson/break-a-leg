extends TextureButton
class_name BaseAbilityButton

@export var ability_count: int = 3
@export var rollback_time: float = 5.

func _ready():
	$Counter.text = str(ability_count)
	if ability_count == 0:
		self.visible = false

func button_rollback(tween_time: float):
	$TextureProgressBar.value = 0
	$TextureProgressBar.visible = true
	var tween = create_tween()
	tween.tween_method(animate_rollback, 0, 100, rollback_time)

func animate_rollback(value: int):
	$TextureProgressBar.value = value
	if value == 100 and ability_count != 0:
		button_enable()
		$TextureProgressBar.visible = false

func button_enable():
	if ability_count > 0:
		self.disabled = false

func _on_pressed():
	ability_count -= 1
	$Counter.text = str(ability_count)
	self.disabled = true
	if ability_count > 0:
		button_rollback(rollback_time)
	else:
		hide_button()
		
func hide_button():
	var tween = create_tween()
	tween.tween_method(self.set_modulate, Color(1, 1, 1, 1), Color(1, 1, 1, 0), 2)
	
