extends Node


@onready var pause_layer: CanvasLayer = %PauseLayer


func _ready() -> void:
	if pause_layer.visible and not get_tree().paused:
		pause_layer.hide()


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pause"):
			_pause()


func _pause() -> void:
	get_tree().paused = not get_tree().paused # Toggle
	pause_layer.visible = get_tree().paused # Show if paused
