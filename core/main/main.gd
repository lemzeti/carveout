class_name Main
extends Node


signal pattern_lost
signal pattern_won


var patterns_uid : Array[String] = [
	"uid://xr7yl2b8yyyx",
]
var current_pattern : Pattern = null

var pattern_index : int = 0 # Level counter, start at 0 because array
var win : bool = false


@onready var pattern_spawner : Marker2D = %PatternSpawner
@onready var pattern_root : Node2D = %PatternRoot

@onready var pause_layer : CanvasLayer = %PauseLayer
@onready var victory_layer : CanvasLayer = %VictoryLayer


func _ready() -> void:
	_init_ui_layers()
	_load_pattern(patterns_uid[pattern_index])
	Game.main_scene = self


func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("pause"):
			_pause()


func _load_pattern(pattern_uid : String) -> void:
	_deferred_load_pattern.call_deferred(pattern_uid)


func _deferred_load_pattern(pattern_uid : String) -> void:
	# Remove current pattern if exists
	if current_pattern != null:
		current_pattern.queue_free()

	await get_tree().process_frame

	var pattern_scene : PackedScene = ResourceLoader.load(pattern_uid)
	if pattern_scene == null:
		push_error("Pattern scene #", pattern_index + 1, " is null.")
		return

	var pattern : Pattern = pattern_scene.instantiate()
	if pattern == null:
		push_error("Pattern #", pattern_index + 1, " instantiation failed.")
		return

	current_pattern = pattern
	pattern.global_position = pattern_spawner.global_position
	pattern_root.add_child(pattern)


func _pause() -> void:
	get_tree().paused = not get_tree().paused # Toggle
	pause_layer.visible = get_tree().paused # Show if paused


func _init_ui_layers() -> void:
	if pause_layer.visible and not get_tree().paused:
		pause_layer.hide()
	if victory_layer.visible:
		victory_layer.hide()


func victory() -> void:
	pattern_won.emit()
	next_pattern()


func true_victory() -> void:
	# add stats like circl used, time taken to beat patterns, etc.
	# add "restart" or "main menu" button
	# add local "previous record" of stats
	victory_layer.show()


func lose() -> void:
	pattern_lost.emit()


func next_pattern() -> void:
	pattern_index += 1
	if pattern_index >= patterns_uid.size():
		Game.true_victory()
		return
	_load_pattern(patterns_uid[pattern_index])
