class_name Pattern
extends Node2D


var good_rectangl : Array[Rectangl] = [] # Target pattern
var bad_rectangl : Array[Rectangl] = [] # Excess pattern


@onready var target_pattern : Node2D = %TargetPattern
@onready var excess_pattern : Node2D = %ExcessPattern


func _ready() -> void:
	for child in target_pattern.get_children():
		if child is Rectangl:
			good_rectangl.append(child)
			child.connect("rectangl_ded", _on_rectangl_ded)
	for child in excess_pattern.get_children():
		if child is Rectangl:
			bad_rectangl.append(child)
			child.connect("rectangl_ded", _on_rectangl_ded)


func _on_rectangl_ded(rec : Rectangl) -> void:
	_check_rectangl(rec)


func _check_rectangl(rec : Rectangl) -> void:
	if rec in good_rectangl:
		Game.lose()
	elif rec in bad_rectangl: # celerate
		bad_rectangl.erase(rec)
	_check_pattern()


func _check_pattern() -> void:
	print("al")
	if bad_rectangl.size() <= 0:
		print("waho")
		Game.victory()
