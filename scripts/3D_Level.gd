extends Node3D

@onready var grid_screen: Node3D = $"Van/Van Model/GridScreen"

var van_grid_loc: Vector2
var van_global_loc: Vector2
var van_dir: String
var city_grid: Node2D
var van: Node2D

func _ready() -> void:
	get_tree().paused = false
	GlobalSignals.grid_screen_pressed.connect(_on_grid_screen_pressed)
	city_grid = grid_screen.find_child("City_Grid")
	van = city_grid.find_child("Van")
	
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
	DirectionList.directions.clear()
	get_tree().change_scene_to_file("res://City_Grid/city_grid.tscn")
	
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
	
