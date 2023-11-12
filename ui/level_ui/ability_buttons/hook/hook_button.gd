extends BaseAbilityButton
class_name HookAbilityButton

func _on_pressed():
	Game.hook_activate.emit()
	ability_count -= 1
	$Counter.text = str(ability_count)
	self.disabled = true
	if ability_count > 0:
		button_rollback(rollback_time)
	else:
		hide_button()
