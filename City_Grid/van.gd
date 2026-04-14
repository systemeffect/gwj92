extends Node2D

signal is_moving
signal is_not_moving

# Match these to TileMapLayer grid size
const TILE_SIZE: Vector2 = Vector2(32, 32)
const MOVE_UNIT: int = 32

@export var VAN_SPEED: float = 4
var target_loc_x: float = 0
var target_loc_y: float = 0
var path: Array[Direction]
var internal_map_van_enabled: bool = false

func _ready() -> void:
	GlobalSignals.red_button_pressed.connect(_on_red_button_pressed)
	path = DirectionList.directions

func _physics_process(delta: float):
	
	var pos = position

	if internal_map_van_enabled == false:
		
		if target_loc_x != 0 and !is_equal_approx(pos.x, target_loc_x):
			pos.x = lerp(pos.x, target_loc_x, VAN_SPEED * delta)
			is_moving.emit()

		elif target_loc_y != 0 and !is_equal_approx(pos.y, target_loc_y):
			pos.y = lerp(pos.y, target_loc_y, VAN_SPEED * delta)
			is_moving.emit()
		else:
			# for some reason this doesnt trigger when the van isnt moving
			#print("not moving")
			target_loc_x = 0
			target_loc_y = 0
			is_not_moving.emit()
		position = pos
	
	else:
		VAN_SPEED = 4
		pos = global_position
		pos.x = move_toward(pos.x, target_loc_x, VAN_SPEED * delta)
		pos.y = move_toward(pos.y, target_loc_y, VAN_SPEED * delta)
		global_position = pos
		
	
func move (dir: String, amt: int) -> void:
	if dir == "WEST":
		target_loc_x = position.x - (amt * MOVE_UNIT)
	if dir == "EAST":
		target_loc_x = position.x + (amt * MOVE_UNIT)
	if dir == "NORTH":
		target_loc_y = position.y - (amt * MOVE_UNIT)
	if dir == "SOUTH":
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

func _on_red_button_pressed() -> void:
	for i in range(path.size()):
		internal_map_van_enabled = true
		var step = path[i]
		move(step.move_direction, step.move_amount)
		await is_not_moving
