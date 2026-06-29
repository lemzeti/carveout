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

@onready var bounce_sfx : AudioStreamPlayer2D = $Bounce
@onready var ded_sfx : AudioStreamPlayer2D = $Ded


func _ready() -> void:
	_update_label()
	bounce_sfx.stream = preload("uid://clxms55ljic0n")
	ded_sfx.stream = load("uid://dk7ger7d5hyk0")


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

	bounce_sfx.pitch_scale = randf_range(0.75, 1.25)
	bounce_sfx.play()

	# Bounce
	direction = direction.bounce(collision_data.get_normal())


func ded() -> void:
	collision.disabled = true
	if is_instance_valid(label):
		label.queue_free()
	sprite.texture = ded_particl
	set_physics_process(false)
	ded_sfx.play()
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
	if health < 0:
		ded()
		return
	_update_label()


func _update_label() -> void:
	label.text = str(health)


func randomize() -> void:
	label.text = ""
	var min_vec : Vector2 = Vector2(50, 50)
	var max_vec : Vector2 = Vector2(1200, 700)
	global_position = Vector2(
		randf_range(min_vec.x, max_vec.x),
		randf_range(min_vec.y, max_vec.y)
	)
	direction = Vector2(
		randf_range(-1.0, 1.0),
		randf_range(-1.0, 1.0)
	).normalized()
	speed = 750.0
	sprite.self_modulate = [
		Color.BLUE,
		Color.RED,
		Color.ORANGE,
		Color.YELLOW,
		Color.GREEN,
		Color.WHITE,
		Color.PINK,
		Color.PURPLE,
		Color.DARK_VIOLET
	].pick_random()
	bounce_sfx.volume_db = -6.0


func disable() -> void:
	set_physics_process(false)


func enable() -> void:
	set_physics_process(true)
