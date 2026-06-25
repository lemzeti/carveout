class_name Main
extends Node


const TRANSITION_TWEEN_DURATION : float = 1.0
const STICKER_TWEEN_DURATION : float = 2.0
const STICKER_SCALE_MAX : Vector2 = Vector2(1.8, 1.8)


# In order; e.g. index 0 = pattern 1, and so on
var pattern_scenes : Array[PackedScene] = [
	preload("uid://xr7yl2b8yyyx"),
	preload("uid://mg0lpby5tws1"),
]

var pattern_preview_image_path : Array[String] = [
	"uid://c853s1o7kblmg",
	"uid://38te1o115b6f",
	"uid://bprheuayo34qr",
	"uid://dxjj4s7rys5rm",
	"uid://4qcctkodfq5y",
	"uid://bpwpnrincf4tk",
	"uid://kll08jyphtf8",
	"uid://c7l435swb58dt",
	"uid://bc7e73jj88k61",
	"uid://dcb4wnthw8drt",
]

var win_sticker : Texture = preload("uid://bbg3o8loen27k")
var lose_sticker : Texture = preload("uid://d0gi2fjqxca0r")

var current_pattern : Pattern = null

var pattern_index : int = 0 # Level counter, start at 0 because array

var win : bool = false

var screen_size : Vector2 = Vector2.ZERO
var default_sticker_scale : Vector2 = Vector2(0.1, 0.1)

var sticker_tween : Tween = null
var transition_tween : Tween = null


@onready var pattern_root : Node2D = %PatternRoot
@onready var pattern_spawner : Marker2D = %PatternSpawner
@onready var pattern_preview : TextureRect = %Pattern

@onready var circl_spawner : CirclSpawner = %CirclSpawner

@onready var sticker : TextureRect = %Sticker
@onready var transition_tween_timer_helper : Timer = %TransitionTweenTimerHelper

@onready var pause_layer : CanvasLayer = %PauseLayer
@onready var victory_layer : CanvasLayer = %VictoryLayer
@onready var transition_layer : CanvasLayer = %TransitionLayer
@onready var transition_color : ColorRect = %TransitionColor


func _ready() -> void:
	_init_ui_layers()

	Game.main_scene = self
	screen_size = get_viewport().get_visible_rect().size
	transition_tween_timer_helper.wait_time = TRANSITION_TWEEN_DURATION / 2.0
	transition_tween_timer_helper.one_shot = true

	_load_pattern(pattern_scenes[pattern_index])


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pause"):
			_pause()


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
	pattern.global_position = pattern_spawner.global_position
	pattern_root.add_child(pattern)


func _pause() -> void:
	get_tree().paused = not get_tree().paused # Toggle
	pause_layer.visible = get_tree().paused # Show if paused


func _init_ui_layers() -> void:
	pause_layer.hide()
	victory_layer.hide()
	transition_layer.hide()
	sticker.hide()
	sticker.scale = default_sticker_scale


func _transition() -> void:
	transition_color.global_position.x = -(screen_size.x)
	transition_layer.show()

	if transition_tween != null:
		transition_tween.kill()

	transition_tween_timer_helper.start()

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

		if transition_color.global_position == Vector2.ZERO:
			transition_tween_timer_helper.start()
			break

func _animate_sticker(prompt : String) -> void:
	# Seriously what the heck is this stupid code
	# Refactor? Nah, we ball
	prompt = prompt.to_lower()
	if prompt == "w": # Win
		sticker.texture = win_sticker
	elif prompt == "l": # Lose
		sticker.texture = lose_sticker
	sticker.show()

	if sticker_tween != null:
		sticker_tween.kill()

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


func _reset_sticker() -> void:
	sticker.hide()
	sticker.scale = default_sticker_scale


func victory() -> void:
	circl_spawner.disable()
	await _animate_sticker("W")
	await _transition()
	await transition_tween_timer_helper.timeout
	_reset_sticker()
	next_pattern()


func true_victory() -> void:
	# add stats like circl used, time taken to beat patterns, etc.
	# add "restart" or "main menu" button
	# add local "previous record" of stats
	victory_layer.show()


func lose() -> void:
	circl_spawner.disable()
	await _animate_sticker("L")
	await _transition()
	await transition_tween_timer_helper.timeout
	_reset_sticker()
	_load_pattern(pattern_scenes[pattern_index])


func next_pattern() -> void:
	pattern_index += 1
	if pattern_index >= pattern_scenes.size():
		Game.true_victory()
		return
	_load_pattern(pattern_scenes[pattern_index])
