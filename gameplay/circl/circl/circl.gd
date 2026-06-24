class_name Circl
extends CharacterBody2D


# Will be set by CirclSpawner
var health : float = 0.0
var speed: float = 0.0
var direction : Vector2 = Vector2.ZERO


func _physics_process(_delta: float) -> void:
	velocity = direction * speed
	move_and_slide()
