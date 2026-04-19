extends Control
@onready var sprite_2d: Sprite2D = $ColorRect/Sprite2D


func _process(delta: float) -> void:
	sprite_2d.rotation += 0.8 * delta
