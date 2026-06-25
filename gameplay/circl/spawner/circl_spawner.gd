class_name CirclSpawner
extends Node2D


const CIRCL_SCENE : PackedScene = preload("uid://cs2o7jr0pm6p6")
const MAX_ROTATION : float = 45.0 # In radians


@export var circl_root : Node2D :
	get:
		if not circl_root:
			circl_root = get_parent()
		return circl_root
@export_group("Editors")
@export var health_editor : HealthEditor = null

@export_group("Circl Stats")
@export var circl_health : int = 5
@export var circl_speed : float = 750.0


var direction : Vector2 = Vector2.ZERO


func _ready() -> void:
	_init_signals()


func _input(event: InputEvent) -> void:
	# Aiming
	if event is InputEventMouseMotion:
		_aim(event.position)

	# Shooting
	if event is InputEventKey:
		if event.is_action_pressed("shoot"):
			_shoot()


func _aim(pos : Vector2) -> void:
	direction = (pos - global_position).normalized()
	look_at(direction) # Temporary, breaks when position != Vec2(0)


func _shoot() -> void:
	var circl : Circl = CIRCL_SCENE.instantiate() as Circl

	circl.health = circl_health
	circl.speed = circl_speed
	circl.direction = direction
	circl.global_position = global_position

	circl_root.add_child(circl)
	Game.circl_used += 1


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
