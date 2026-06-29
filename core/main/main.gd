class_name Main
extends Node


const TRANSITION_TWEEN_DURATION : float = 1.0
const STICKER_TWEEN_DURATION : float = 3.0
const STICKER_SCALE_MAX : Vector2 = Vector2(2.0, 2.0)


# In order; e.g. index 0 = pattern 1, and so on
var pattern_scenes : Array[PackedScene] = [
	preload("uid://xr7yl2b8yyyx"),
	preload("uid://mg0lpby5tws1"),
	preload("uid://b6q4dtga3jtet"),
	preload("uid://dahwtyo7lckba"),
	preload("uid://cjo4okshn6b4f"),
	preload("uid://c7q4u3g17n07y"),
	preload("uid://b37dsbjdfx242"),
	preload("uid://kgp6nu4adgw8"),
	preload("uid://chd6dhx82p0xx"),
	preload("uid://b2qy6n2io177g"),
]

var pattern_preview_image_path : Array[String] = [
	"uid://dlm4ca6bi310u",
	"uid://ba0qkvrqq3sx0",
	"uid://ccsp7q6vhuvww",
	"uid://dx7vkbivhlnkv",
	"uid://b52dejsowr3r",
	"uid://cuuqv5oy6vdpf",
	"uid://bmkpuuvtmdq3l",
	"uid://cq5r0llnro32a",
	"uid://bjrkg1aqf33pj",
	"uid://bnfjo2pd4rute",
]

var win_sticker : Texture = preload("uid://bbg3o8loen27k")
var lose_sticker : Texture = preload("uid://d0gi2fjqxca0r")

var lose_stream := preload("uid://dmiw6d3hlthuh")
var win_stream := preload("uid://brig0j5dsaf1k")


var current_pattern : Pattern = null

var pattern_index : int = 0 # Level counter

var win : bool = false

var screen_size : Vector2 = Vector2.ZERO
var default_sticker_scale : Vector2 = Vector2(0.1, 0.1)

var sticker_tween : Tween = null
var transition_tween : Tween = null


@onready var pattern_root : Node2D = %PatternRoot
@onready var pattern_spawner : Marker2D = %PatternSpawner
@onready var pattern_preview : TextureRect = %Pattern
@onready var boundary_root : Node2D = %BoundaryRoot

@onready var bgm : AudioStreamPlayer = %BGM
@onready var pattern_wl : AudioStreamPlayer = %PatternWL
@onready var start_game : AudioStreamPlayer = %StartGame

@onready var circl_spawner : CirclSpawner = %CirclSpawner
@onready var circl_root : Node2D = %CirclRoot

@onready var happy_points : Label = %HappyPoints
@onready var sad_points : Label = %SadPoints

@onready var sticker : TextureRect = %Sticker
@onready var menu_circls : Node2D = %MenuCircls

@onready var pause_layer : CanvasLayer = %PauseLayer
@onready var victory_layer : CanvasLayer = %VictoryLayer
@onready var sticker_layer : CanvasLayer = %StickerLayer
@onready var transition_layer : CanvasLayer = %TransitionLayer
@onready var transition_color : ColorRect = %TransitionColor
@onready var main_menu_layer : CanvasLayer = %MainMenuLayer
@onready var tutorial : Label = %Tutorial


func _ready() -> void:
	_init_ui_layers()

	Game.main_scene = self
	screen_size = get_viewport().get_visible_rect().size

	bgm.stream = preload("uid://bbi22mypu8b8b")
	bgm.volume_db = -15.0
	bgm.play()

	start_game.stream = preload("uid://oewkfs00uf1c")
	start_game.volume_db = -7.0

	_load_pattern(pattern_scenes[pattern_index])


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pause"):
			_pause()


func _process(_delta: float) -> void:
	if not bgm.playing:
		bgm.play()


func _load_pattern(scene : PackedScene) -> void:
	_deferred_load_pattern.call_deferred(scene)


func _deferred_load_pattern(scene : PackedScene) -> void:
	# Remove current pattern if exists
	if current_pattern != null:
		current_pattern.queue_free()

	await get_tree().process_frame

	# Just in case idk
	if scene == null:
		push_error("Pattern scene #", pattern_index + 1, " is null.")
		return

	# Instantiate pattern
	var pattern : Pattern = scene.instantiate()
	if pattern == null:
		push_error("Pattern #", pattern_index + 1, " instantiation failed.")
		return

	# Update pattern preview
	pattern_preview.texture = load(
		pattern_preview_image_path[pattern_index]
		)

	circl_spawner.enable()

	# Add pattern to scene
	current_pattern = pattern
	Game.current_pattern_num = pattern_index + 1
	pattern.global_position = pattern_spawner.global_position
	pattern_root.add_child(pattern)

	if Game.current_pattern_num <= 5:
		_tutorial()
	elif Game.current_pattern_num > 5:
		_health_tutorial()


func _tutorial() -> void:
	tutorial.text = "Match the pattern!"


func _health_tutorial() -> void:
	tutorial.text = "Match the colors!\nAnd the pattern!"


func _pause() -> void:
	get_tree().paused = not get_tree().paused # Toggle
	pause_layer.visible = get_tree().paused # Show if paused


func _init_ui_layers() -> void:
	main_menu_layer.show()
	pause_layer.hide()
	victory_layer.hide()
	transition_layer.hide()
	sticker.hide()
	sticker.scale = default_sticker_scale
	for circl in menu_circls.get_children():
		circl.randomize()
	for boundary in boundary_root.get_children():
		if boundary is Boundary:
			boundary.process_mode = Node.PROCESS_MODE_DISABLED
			for collision in boundary.get_children():
				if collision is CollisionShape2D:
					collision.disabled = true


func _transition(prompt : String) -> void:
	transition_color.global_position.x = -(screen_size.x + (transition_color.size.x - screen_size.x))
	transition_layer.show()

	prompt = prompt.to_lower()

	if transition_tween != null:
		transition_tween.kill()

	transition_tween = get_tree().create_tween()
	transition_tween.tween_property(
		transition_color,
		"global_position:x",
		screen_size.x,
		TRANSITION_TWEEN_DURATION
	).set_trans(
		Tween.TRANS_SINE).set_ease(
			Tween.EASE_IN_OUT
		)

	# Check if transition has reached halfway point
	# It seems I don't care about code readabilit and optimaitaizon anymore
	# At least in this project lol
	while transition_tween.is_running():
		await get_tree().process_frame

		if transition_color.global_position >= Vector2.ZERO:
			_reset_sticker()
			if prompt == "w": # Win
				next_pattern()
			elif prompt == "l": # Lose
				_load_pattern(pattern_scenes[pattern_index])
			break

func _animate_sticker(prompt : String) -> void:
	# Seriously what the heck is this stupid code
	# Refactor? Nah, we ball
	prompt = prompt.to_lower()
	if prompt == "w": # Win
		sticker.texture = win_sticker
		pattern_wl.stream = win_stream
	elif prompt == "l": # Lose
		sticker.texture = lose_sticker
		pattern_wl.stream = lose_stream

	if not sticker_layer.visible:
		sticker_layer.show()
	sticker.show()

	if sticker_tween != null:
		sticker_tween.kill()

	pattern_wl.play()

	sticker_tween = get_tree().create_tween()
	sticker_tween.tween_property(
		sticker,
		"scale",
		STICKER_SCALE_MAX,
		STICKER_TWEEN_DURATION
	).set_trans(
		Tween.TRANS_ELASTIC).set_ease(
			Tween.EASE_OUT)

	await sticker_tween.finished
	Game.sad_stickers += 1


func _reset_sticker() -> void:
	sticker.hide()
	sticker_layer.hide()
	sticker.scale = default_sticker_scale


func _ded_all_circl() -> void:
	for child in circl_root.get_children():
		if child is Circl:
			child.set_physics_process(false)
			if not is_instance_valid(child):
				return
			child.ded()


func victory() -> void:
	circl_spawner.disable()
	Game.happy_stickers += 1
	circl_spawner.aim_trajectory.clear_points()
	_ded_all_circl()
	await _animate_sticker("W")
	await _transition("W")


func true_victory() -> void:
	await transition_tween.finished
	# add stats like circl used, time taken to beat patterns, etc.
	# add "restart" or "main menu" button
	# add local "previous record" of stats
	happy_points.text = str(Game.happy_stickers)
	sad_points.text = str(Game.sad_stickers)
	victory_layer.show()


func lose() -> void:
	bgm.stream_paused = true
	Game.sad_stickers += 1
	circl_spawner.disable()
	circl_spawner.aim_trajectory.clear_points()
	_ded_all_circl()
	await get_tree().create_timer(1.0).timeout
	await _animate_sticker("L")
	await _transition("L")
	bgm.stream_paused = false


func next_pattern() -> void:
	pattern_index += 1
	if pattern_index >= pattern_scenes.size():
		Game.true_victory()
		return
	_load_pattern(pattern_scenes[pattern_index])


func _on_restart_button_pressed() -> void:
	if transition_tween:
		transition_tween.kill()
	if sticker_tween:
		sticker_tween.kill()
	circl_spawner.disable()
	circl_spawner.aim_trajectory.clear_points()
	_ded_all_circl()
	await _transition("L")


func _on_aim_guide_toggle_toggled(toggle: bool) -> void:
	circl_spawner.trajectory_guide_enabled = toggle
	circl_spawner.aim_trajectory.clear_points()


func _on_play_pressed() -> void:
	main_menu_layer.hide()
	bgm.volume_db = -18.0
	start_game.play()
	for circl in menu_circls.get_children():
		circl.disable()
	for boundary in boundary_root.get_children():
		if boundary is Boundary:
			boundary.process_mode = Node.PROCESS_MODE_INHERIT
			for collision in boundary.get_children():
				if collision is CollisionShape2D:
					collision.disabled = false


func _on_main_menu_button_pressed() -> void:
	for circl in menu_circls.get_children():
		circl.randomize()
		circl.enable()
	_init_ui_layers()
	bgm.volume_db = -15.0


func _on_next_level_pressed() -> void:
	await _transition("")
	next_pattern()


func _on_victory_main_menu_button_pressed() -> void:
	for circl in menu_circls.get_children():
		circl.randomize()
		circl.enable()
	_init_ui_layers()
	bgm.volume_db = -15.0
	pattern_index = 0
	_load_pattern(pattern_scenes[pattern_index])
