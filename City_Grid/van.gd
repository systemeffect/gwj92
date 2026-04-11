extends Sprite2D

func _physics_process(delta: float) -> void:
	global_position.y -= 5 * delta
