extends Node


const MAX_HEALTH : int = 4
const MIN_HEALTH : int = 0


var circl_used : int = 0

var happy_stickers : int = 0
var sad_stickers : int = 0


var main_scene : Main = null
var current_pattern_num : int = 0


func victory() -> void:
	print("wow you beat nth pattern")
	main_scene.victory()


func true_victory() -> void:
	main_scene.true_victory()


func lose() -> void:
	print("womp womp")
	main_scene.lose()
