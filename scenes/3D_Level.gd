extends Node3D

@onready var grid_screen: Node3D = $"Van/Van Model/GridScreen"

var van_grid_loc: Vector2
var van_global_loc: Vector2

func _ready() -> void:
	GlobalSignals.grid_screen_pressed.connect(_on_grid_screen_pressed)
	
func _on_grid_screen_pressed() -> void:
	DirectionList.directions.clear()
	van_grid_loc = grid_screen.find_child("City_Grid").get_van_grid_coords()
	van_global_loc = grid_screen.find_child("City_Grid").find_child("Van").global_position
	GlobalLocations.van_grid_loc = van_grid_loc
	GlobalLocations.van_global_loc = van_global_loc
	get_tree().change_scene_to_file("res://City_Grid/city_grid.tscn")
