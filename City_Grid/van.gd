extends Sprite2D

signal is_moving
signal is_not_moving

# Match these to TileMapLayer grid size
const TILE_SIZE: Vector2 = Vector2(32, 32)
const MOVE_UNIT: int = 32

@export var VAN_SPEED: float = 4
var target_loc_x: float = 0
var target_loc_y: float = 0

func _ready() -> void:
	#GlobalSignals.clicked.connect(_on_clicked)
	pass

func _physics_process(delta: float):
	
	var pos = position
	if pos.x == target_loc_x:
		target_loc_x = 0
	if target_loc_x != 0:
		pos.x = lerp(pos.x, target_loc_x, VAN_SPEED * delta)
		is_moving.emit()

	elif target_loc_y != 0:
		pos.y = lerp(pos.y, target_loc_y, VAN_SPEED * delta)
		is_moving.emit()
	else:
		# for some reason this doesnt trigger when the van isnt moving
		#print("not moving")
		is_not_moving.emit()
	position = pos
	
	
func move (dir: String, amt: int) -> void:
	if dir == "LEFT":
		target_loc_x = position.x - (amt * MOVE_UNIT)
	if dir == "RIGHT":
		target_loc_x = position.x + (amt * MOVE_UNIT)
	if dir == "UP":
		target_loc_y = position.y - (amt * MOVE_UNIT)
	if dir == "DOWN":
		target_loc_y = position.y + (amt * MOVE_UNIT)

#func _input(event: InputEvent) -> void:
	#if event.is_action_pressed("ui_left"):
		#move("left")
	#if event.is_action_pressed("ui_right"):
		#move("right")
	#if event.is_action_pressed("ui_up"):
		#move("up")
	#if event.is_action_pressed("ui_down"):
		#move("down")

#func _on_clicked() -> void:
	#move("left")
