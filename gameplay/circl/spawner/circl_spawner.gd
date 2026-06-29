class_name CirclSpawner
extends CharacterBody2D


const CIRCL_SCENE : PackedScene = preload("uid://cs2o7jr0pm6p6")
const MAX_ROTATION : float = 45.0 # In radians
const MAX_TRAJECTORY_POINTS : int = 2


@export var circl_root : Node2D :
	get:
		if not circl_root:
			circl_root = get_parent()
		return circl_root
@export_group("Editors")
@export var health_editor : HealthEditor = null

@export_group("Circl Stats")
@export var circl_health : int = 2
@export var circl_speed : float = 750.0


var aim_direction : Vector2 = Vector2.ZERO

var move_speed : float = 500.0
var move_direction : float = 0.0

var trajectory_guide_enabled : bool = true
var bounce_count : int = 0


@onready var sprite : Sprite2D = %Sprite
@onready var aim_trajectory : Line2D = %AimTrajectory
@onready var bounce_check : CharacterBody2D = %BounceCheck


func _ready() -> void:
	_init_signals()


func _input(event: InputEvent) -> void:
	# Shooting ????ADSASD
	if event.is_action_pressed("shoot"):
		_shoot()


func _physics_process(_delta: float) -> void:
	_aim()
	_update_trajectory()

	# ???
	move_direction = Input.get_axis("move_left", "move_right")
	# ?
	velocity.x = move_direction * move_speed
	move_and_slide()
	# j


func _aim() -> void:
	aim_direction = (get_global_mouse_position() - global_position).normalized()
	sprite.look_at(get_global_mouse_position())


func _shoot() -> void:
	var circl : Circl = CIRCL_SCENE.instantiate() as Circl

	circl.health = circl_health
	circl.speed = circl_speed
	circl.direction = aim_direction
	circl.global_position = global_position

	circl_root.add_child(circl)
	Game.circl_used += 1


func _update_trajectory() -> void:
	if not trajectory_guide_enabled:
		return

	bounce_count = 0

	# Clear previous trajectory
	aim_trajectory.clear_points()

	# Simulate actual Circl
	var traj_position : Vector2 = Vector2.ZERO
	var traj_direction : Vector2 = aim_direction
	var traj_motion : Vector2 = traj_direction * circl_speed

	# Draw points
	for i in MAX_TRAJECTORY_POINTS:
		aim_trajectory.add_point(traj_position)

		# Bounce off stuff
		var collision := bounce_check.move_and_collide(traj_motion, true)
		if collision and bounce_count == 0:
			traj_direction = traj_direction.bounce(collision.get_normal())

		traj_position += traj_motion
		bounce_check.position = traj_position


func _init_signals() -> void:
	health_editor.connect("text_changed", _on_health_edited)


func _on_health_edited(text : String) -> void:
	if not text.is_valid_int():
		push_error(
			"Please enter only numbers from %d to %d!" % 
			[Game.MIN_HEALTH, Game.MAX_HEALTH])
		return

	var value : int = text.to_int()

	# Loops value 1-5
	if value > Game.MAX_HEALTH:
		value = Game.MIN_HEALTH
	elif value < Game.MIN_HEALTH:
		value = Game.MAX_HEALTH

	circl_health = value
	#print("latest health: %d" % circl_health)


func disable() -> void:
	set_process_input(false)
	set_physics_process(false)


func enable() -> void:
	set_process_input(true)
	set_physics_process(true)
