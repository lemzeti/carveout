class_name Rectangl
extends StaticBody2D


@warning_ignore("unused_signal")
signal rectangl_ded(rec : Rectangl)


@export_range(1, 100, 1) var health : int = 1


@onready var label: Label = %Label


func _ready() -> void:
	_update_label()


func decrement_health(amount : int) -> void:
	health -= amount
	if health <= 0:
		rectangl_ded.emit(self)
		queue_free()
		return
	_update_label()


func _update_label() -> void:
	label.text = str(health)
