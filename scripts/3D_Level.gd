extends Node3D

@onready var grid_screen: Node3D = $"Van/Van Model/GridScreen"

var van_grid_loc: Vector2
var van_global_loc: Vector2
var van_dir: String
var city_grid: Node2D
var van: Node2D
var action_ui : Control

var turn_ended : bool = false

func _ready() -> void:
	get_tree().paused = false
	GlobalSignals.grid_screen_pressed.connect(_on_grid_screen_pressed)
	city_grid = grid_screen.find_child("City_Grid")
	van = city_grid.find_child("Van")
	van.is_not_moving.connect(check_end_of_path)
	var ui = city_grid.find_child("UI")
	action_ui = ui.find_child("ActionsUI")
	
#func _process(delta: float) -> void:
	#if !turn_ended:
		#check_end_of_path()
	
func check_end_of_path():
	var status_grid = city_grid.status_effects
	GlobalLocations.van_grid_loc = status_grid.local_to_map(van.position)
	if GlobalLocations.van_grid_loc == GlobalLocations.turn_end_coords:
		print("end this MF turn")
		turn_ended = true
		action_ui.process_turn()
	
func _on_grid_screen_pressed() -> void:
	#Grabbing Van Location and shit
	van_grid_loc = city_grid.get_van_grid_coords()
	van_global_loc = van.global_position
	van_dir = van.direction_copy.back().move_direction
	#clear the copy just to avoid anything growing
	van.direction_copy.clear()
	GlobalLocations.current_turn += 1
	GlobalLocations.van_grid_loc = van_grid_loc
	GlobalLocations.van_global_loc = van_global_loc
	GlobalLocations.van_global_dir = van_dir
	var cur_storm_locs = get_storm_locs()
	GlobalLocations.storm_locs = cur_storm_locs
	get_sensors()
	get_fires_floods()
	DirectionList.directions.clear()
	get_tree().change_scene_to_file("res://City_Grid/city_grid.tscn")
	
func get_fires_floods():
	var tilemap = city_grid.status_effects
	var fire_array = tilemap.get_used_cells_by_id(0,Vector2(2,0))
	GlobalLocations.fire_locs = fire_array
	var flood_array = tilemap.get_used_cells_by_id(0,Vector2(3,0))
	GlobalLocations.flood_locs = flood_array

func get_storm_locs() -> Array:
	var storms_array = []
	var container = city_grid.storms_container
	var storms = container.get_children()
	for storm in storms:
		var loc = storm.global_position
		storms_array.append(loc)
	return storms_array
	
func get_sensors():
	var tilemap = city_grid.status_effects
	var sensor_array = tilemap.get_used_cells_by_id(0,Vector2(4,0))
	GlobalLocations.sensor_locs = sensor_array
	
