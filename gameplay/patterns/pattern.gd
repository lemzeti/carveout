class_name Pattern
extends Node2D


# For pattern 6-10
var target_rectangl_health : Dictionary[Rectangl, int] = {}
var target_health_reached : Array[Rectangl] = [] # yep

var good_rectangl : Array[Rectangl] = [] # Target pattern
var bad_rectangl : Array[Rectangl] = [] # Excess pattern


@onready var target_pattern : Node2D = %TargetPattern
@onready var excess_pattern : Node2D = %ExcessPattern


func _ready() -> void:
	for child in target_pattern.get_children():
		if child is Rectangl:
			good_rectangl.append(child)
			child.connect("rectangl_ded", _on_rectangl_ded)
			child.connect("rectangl_hit", _on_rectangl_hit)
			target_rectangl_health[child as Rectangl] = child.target_health
			if Game.current_pattern_num >= 5:
				_check_rectangl_health(child)
	for child in excess_pattern.get_children():
		if child is Rectangl:
			bad_rectangl.append(child)
			child.connect("rectangl_ded", _on_rectangl_ded)


func _on_rectangl_ded(rec : Rectangl) -> void:
	if Game.current_pattern_num <= 5:
		_check_rectangl(rec)


func _on_rectangl_hit(rec : Rectangl) -> void:
	if Game.current_pattern_num > 5:
		_check_rectangl_health(rec)


func _check_rectangl(rec : Rectangl) -> void:
	if rec in good_rectangl:
		Game.lose()
	elif rec in bad_rectangl: # celerate
		bad_rectangl.erase(rec)
	_check_pattern()


func _check_rectangl_health(rec : Rectangl) -> void:
	var rec_target_health : int = target_rectangl_health.get(rec)
	if rec.health < rec_target_health:
		Game.lose()
	elif rec.health == rec_target_health:
		target_health_reached.append(rec)

	_check_health_pattern()


func _check_pattern() -> void:
	if bad_rectangl.size() <= 0:
		Game.victory()


func _check_health_pattern() -> void:
	if good_rectangl.size() == target_health_reached.size():
		Game.victory()
