extends Sprite2D

@export var VAN_SPEED: float = 45
var target_loc_x: float = 0
var target_loc_y: float = 0

func _process(delta):
	var pos = position
	
	if target_loc_x != 0:
		pos.x = lerp(pos.x, target_loc_x, VAN_SPEED * delta)
	
	if target_loc_y != 0:
		pos.y = lerp(pos.y, target_loc_y, VAN_SPEED * delta)
	position = pos
	
func move (dir: String) -> void:
	if dir == "left":
		target_loc_x = position.x - 48.0
	if dir == "right":
		target_loc_x = position.x + 48.0
	if dir == "up":
		target_loc_y = position.y - 48.0
	if dir == "down":
		target_loc_y = position.y + 48.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_left"):
		move("left")
	if event.is_action_pressed("ui_right"):
		move("right")
	if event.is_action_pressed("ui_up"):
		move("up")
	if event.is_action_pressed("ui_down"):
		move("down")
