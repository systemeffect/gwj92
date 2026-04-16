extends Node3D

@onready var grid_screen: Node3D = $"Van/Van Model/GridScreen"

var van_grid_loc: Vector2
var van_global_loc: Vector2
var van_dir: String
var city_grid: Node2D
var van: Node2D

func _ready() -> void:
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
	
	GlobalLocations.van_grid_loc = van_grid_loc
	GlobalLocations.van_global_loc = van_global_loc
	GlobalLocations.van_global_dir = van_dir
	
	DirectionList.directions.clear()
	get_tree().change_scene_to_file("res://City_Grid/city_grid.tscn")
