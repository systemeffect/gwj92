extends Node2D

signal is_moving
signal is_not_moving

# Match these to TileMapLayer grid size
const TILE_SIZE: Vector2 = Vector2(32, 32)
const MOVE_UNIT: int = 32

@export var VAN_SPEED: float = 4.0

var target_loc_x: float = 0.0
var target_loc_y: float = 0.0
var current_axis: String = ""
var path: Array[Direction]
var internal_map_van_enabled: bool = false


func _ready():
	GlobalSignals.red_button_pressed.connect(_on_red_button_pressed)
	path = DirectionList.directions

func _physics_process(delta: float):
	var pos = global_position

	if internal_map_van_enabled == false:
		#CityGrid Van
		if current_axis == "x":
			pos.x = lerp(pos.x, target_loc_x, VAN_SPEED * delta)
			is_moving.emit()
			
			if is_equal_approx(pos.x, target_loc_x):
				pos.x = target_loc_x
				current_axis = ""
				is_not_moving.emit()
				
		elif current_axis == "y":
			pos.y = lerp(pos.y, target_loc_y, VAN_SPEED * delta)
			is_moving.emit()
			
			if is_equal_approx(pos.y, target_loc_y):
				pos.y = target_loc_y
				current_axis = ""
				is_not_moving.emit()
				
		global_position = pos
		
	else:
		# for some reason this doesnt trigger when the van isnt moving
		#print("not moving")
		target_loc_x = 0
		target_loc_y = 0
		is_not_moving.emit()
	position = pos
	

func move(dir: Card.DIRECTION, amt: int):
	match dir:
		Card.DIRECTION.west:
			target_loc_x = global_position.x - (amt * MOVE_UNIT)
			target_loc_y = global_position.y
			current_axis = "x"
		Card.DIRECTION.east:
			target_loc_x = global_position.x + (amt * MOVE_UNIT)
			target_loc_y = global_position.y
			current_axis = "x"
		Card.DIRECTION.north:
			target_loc_y = global_position.y - (amt * MOVE_UNIT)
			target_loc_x = global_position.x
			current_axis = "y"
		Card.DIRECTION.south:
			target_loc_y = global_position.y + (amt * MOVE_UNIT)
			target_loc_x = global_position.x
			current_axis = "y"

func _on_red_button_pressed() -> void:
	internal_map_van_enabled = true
	path = DirectionList.directions
	
	for i in range(path.size()):
		var step = path[i]
		print("Running step ", i, ": ", step.move_direction, " / ", step.move_amount)
		move(step.move_direction, step.move_amount)
		await is_not_moving
		
