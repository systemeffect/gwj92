extends Node2D

signal is_moving
signal is_not_moving

@export var VAN_SPEED: float = 4

# van collider
@onready var area_2d: Area2D = $Area2D

# Match these to TileMapLayer grid size
const TILE_SIZE: Vector2 = Vector2(32, 32)
const MOVE_UNIT: int = 32

var target_loc_x: float = 0.0
var target_loc_y: float = 0.0
var current_axis: String = ""
var path: Array[Direction]
var internal_map_van_enabled: bool = false
var turn_direction: String = ""
var is_turning: bool = false
var is_currently_moving: bool = false
var has_started_run: bool = false
var direction_copy = DirectionList.directions

@export var TURN_DURATION: float = 2

func _ready() -> void:
	GlobalSignals.red_button_pressed.connect(_on_red_button_pressed)
	path = DirectionList.directions

func _physics_process(delta: float) -> void:
	var pos = global_position

	if internal_map_van_enabled == false:
		# CityGrid Van
		if current_axis == "x":
			is_currently_moving = true
			pos.x = lerp(pos.x, target_loc_x, VAN_SPEED * delta)
			is_moving.emit()

			if abs(pos.x - target_loc_x) < 0.5:
				pos.x = target_loc_x
				current_axis = ""
				is_currently_moving = false
				is_not_moving.emit()

		elif current_axis == "y":
			is_currently_moving = true
			pos.y = lerp(pos.y, target_loc_y, VAN_SPEED * delta)
			is_moving.emit()

			if abs(pos.y - target_loc_y) < 0.5:
				pos.y = target_loc_y
				current_axis = ""
				is_currently_moving = false
				is_not_moving.emit()
		else:
			is_currently_moving = false

		global_position = pos
		
	else:
		#Internal Van
		VAN_SPEED = 4.0
		
		if current_axis == "x":
			is_currently_moving = true
			pos.x = move_toward(pos.x, target_loc_x, VAN_SPEED * delta)
			is_moving.emit()
			
			if abs(pos.x - target_loc_x) < 0.5:
				pos.x = target_loc_x
				current_axis = ""
				is_currently_moving = false
				is_not_moving.emit()
				
		elif current_axis == "y":
			is_currently_moving = true
			pos.y = move_toward(pos.y, target_loc_y, VAN_SPEED * delta)
			is_moving.emit()
			
			if abs(pos.y - target_loc_y) < 0.5:
				pos.y = target_loc_y
				current_axis = ""
				is_currently_moving = false
				is_not_moving.emit()
		else:
			is_currently_moving = false
			
		global_position = pos

func move(dir: String, amt: int) -> void:
	if dir == "WEST":
		target_loc_x = global_position.x - (amt * MOVE_UNIT)
		target_loc_y = global_position.y
		current_axis = "x"
		
	elif dir == "EAST":
		target_loc_x = global_position.x + (amt * MOVE_UNIT)
		target_loc_y = global_position.y
		current_axis = "x"
		
	elif dir == "NORTH":
		target_loc_y = global_position.y - (amt * MOVE_UNIT)
		target_loc_x = global_position.x
		current_axis = "y"
		
	elif dir == "SOUTH":
		target_loc_y = global_position.y + (amt * MOVE_UNIT)
		target_loc_x = global_position.x
		current_axis = "y"

#Figures out what turn is coming
func get_turn_type(from_dir: String, to_dir: String) -> String:
	if from_dir == "" or from_dir == to_dir:
		return "straight"

	match from_dir:
		"NORTH":
			if to_dir == "EAST":
				return "right"
			elif to_dir == "WEST":
				return "left"
			elif to_dir == "SOUTH":
				return "u_turn"

		"EAST":
			if to_dir == "SOUTH":
				return "right"
			elif to_dir == "NORTH":
				return "left"
			elif to_dir == "WEST":
				return "u_turn"

		"SOUTH":
			if to_dir == "WEST":
				return "right"
			elif to_dir == "EAST":
				return "left"
			elif to_dir == "NORTH":
				return "u_turn"

		"WEST":
			if to_dir == "NORTH":
				return "right"
			elif to_dir == "SOUTH":
				return "left"
			elif to_dir == "EAST":
				return "u_turn"

	return "straight"

func get_turn_info(turn: String) -> Dictionary:
	return {
		"is_turning": turn != "straight" and turn != "none",
		"direction": turn
	}

func do_turn(direction: String) -> void:
	is_turning = true
	turn_direction = direction

	print("Turning now: ", is_turning, " | Turn Type: ", turn_direction)

	await get_tree().create_timer(TURN_DURATION).timeout

	is_turning = false
	turn_direction = "none"

	print("Turn complete. Turning: ", is_turning)


#Starts car movement, can be plugged in anywhere
func _on_red_button_pressed() -> void:
	internal_map_van_enabled = true
	
	#Need this for copy of direction, gets cleared when switching to 2D scene in "3D_Level.gd"
	direction_copy = DirectionList.directions.duplicate()
	
	while DirectionList.directions.size() > 0:

		var step = DirectionList.directions[0]
		var current_dir = step.move_direction

		is_turning = false
		turn_direction = "none"

		move(current_dir, step.move_amount)
		await is_not_moving

		DirectionList.directions.pop_front()
			
		if DirectionList.directions.size() > 0:
			var next_dir = DirectionList.directions[0].move_direction
			var next_turn = get_turn_type(current_dir, next_dir)

			if next_turn != "straight" and next_turn != "none":
				await do_turn(next_turn)
				
