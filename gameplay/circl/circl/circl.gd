class_name Circl
extends CharacterBody2D


# Will be set by CirclSpawner
var health : int = 0
var speed: float = 0.0
var direction : Vector2 = Vector2.ZERO

var ded_particl : Texture = preload("uid://c0mu7mn1m3k5o")


@onready var label : Label = %Label
@onready var sprite : Sprite2D = %Sprite
@onready var collision : CollisionShape2D = %Collision


func _ready() -> void:
	_update_label()


func _physics_process(delta : float) -> void:
	var motion : Vector2 = direction * speed * delta
	var collision_data : KinematicCollision2D = move_and_collide(motion)

	if collision_data:
		_bounce(collision_data)


func _bounce(collision_data : KinematicCollision2D) -> void:
	# Circl hits Rectangl, -1 health for both
	if collision_data.get_collider() is Rectangl:
		var rectangl : Rectangl = collision_data.get_collider() as Rectangl
		rectangl.decrement_health(1)
		decrement_health(1)

	# Bounce
	direction = direction.bounce(collision_data.get_normal())


func ded() -> void:
	collision.disabled = true
	if is_instance_valid(label):
		label.queue_free()
	sprite.texture = ded_particl
	set_physics_process(false)
	await get_tree().create_timer(0.5).timeout
	var tween : Tween = get_tree().create_tween()
	tween.tween_property(
		sprite,
		"self_modulate:a",
		0,
		0.5
	)
	await tween.finished
	queue_free()


func decrement_health(amount : int) -> void:
	health -= amount
	if health <= 0:
		ded()
		return
	_update_label()


func _update_label() -> void:
	label.text = str(health)
