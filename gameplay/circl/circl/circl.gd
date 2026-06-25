class_name Circl
extends CharacterBody2D


# Will be set by CirclSpawner
var health : int = 0
var speed: float = 0.0
var direction : Vector2 = Vector2.ZERO


@onready var label: Label = %Label


func _ready() -> void:
	_update_label()


func _physics_process(delta: float) -> void:
	var motion : Vector2 = direction * speed * delta
	var collision : KinematicCollision2D = move_and_collide(motion)

	if collision:
		_bounce(collision)


func _bounce(collision : KinematicCollision2D) -> void:
	# Circl hits Rectangl, -1 health for both
	if collision.get_collider() is Rectangl:
		var rectangl : Rectangl = collision.get_collider() as Rectangl
		rectangl.decrement_health(1)
		decrement_health(1)

	# Bounce
	direction = direction.bounce(collision.get_normal())


func decrement_health(amount : int) -> void:
	health -= amount
	if health <= 0:
		queue_free()
		return
	_update_label()


func _update_label() -> void:
	label.text = str(health)
