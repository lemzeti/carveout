class_name HealthEditor
extends LineEdit


var value : int = 1


func _ready() -> void:
	text = str(value)


func _on_text_changed(new_text : String) -> void:
	if not new_text.is_valid_int():
		return

	value = new_text.to_int()

	if value > Game.MAX_HEALTH:
		text = str(Game.MIN_HEALTH)
		value = Game.MIN_HEALTH


func _on_decrement_health_pressed() -> void:
	print("val before: ", value)
	value -= 1
	print("val after: ", value)

	if value < Game.MIN_HEALTH:
		value = Game.MAX_HEALTH

	_update_text(str(value))
	text_changed.emit(str(value))


func _on_increment_health_pressed() -> void:
	value += 1

	if value > Game.MAX_HEALTH:
		value = Game.MIN_HEALTH

	_update_text(str(value))
	text_changed.emit(str(value))


func _update_text(new : String) -> void:
	text = new
