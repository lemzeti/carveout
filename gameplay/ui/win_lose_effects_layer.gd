extends CanvasLayer


@export var main_scene : Main :
	get:
		if not main_scene:
			main_scene = get_parent()
		return main_scene
@export var animation_duration : float = 2.0


var lose_effects : Array = [
	load("res://assets/art/lose/blue.png"),
	load("res://assets/art/lose/noooo.png"),
	load("res://assets/art/lose/spong.png"),
]

var win_effects : Array = [
	load("res://assets/art/win/happy.png"),
	load("res://assets/art/win/yippee.png"),
]

var original_scale : Vector2 = Vector2(0.5, 0.5)


@onready var image : TextureRect = %Image


func _ready() -> void:
	image.hide()
	image.scale = original_scale
	main_scene.connect("pattern_won", _on_pattern_won)
	main_scene.connect("pattern_lost", _on_pattern_lost)

func _on_pattern_won() -> void:
	image.texture = win_effects.pick_random()
	await _animate()



func _on_pattern_lost() -> void:
	image.texture = lose_effects.pick_random()
	await _animate()


func _animate() -> void:
	image.show()

	var tween := get_tree().create_tween()
	tween.tween_property(
		image,
		"scale",
		scale * 1.25,
		animation_duration
	).set_trans(
		Tween.TRANS_ELASTIC).set_ease(
			Tween.EASE_OUT)

	await tween.finished

	image.hide()
	image.scale = original_scale
