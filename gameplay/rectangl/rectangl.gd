class_name Rectangl
extends StaticBody2D


@warning_ignore("unused_signal")
signal rectangl_ded(rec : Rectangl)


@export_range(1, 3, 1) var health : int = 3
@export_group("Health Colors")
@export var three_health : Color = Color.RED
@export var two_health : Color = Color.ORANGE
@export var one_health : Color = Color.YELLOW


@onready var sprite: Sprite2D = %Sprite


func _ready() -> void:
	_recolor_according_to_health()


func decrement_health(amount : int) -> void:
	health -= amount
	_recolor_according_to_health()
	if health <= 0:
		rectangl_ded.emit(self)
		queue_free()
		return


func _recolor_according_to_health() -> void:
	match health:
		3: sprite.self_modulate = three_health
		2: sprite.self_modulate = two_health
		1: sprite.self_modulate = one_health
