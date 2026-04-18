extends Node3D

@export var player: CharacterBody3D
@export var camera_lerp_speed: float = 5.0
@onready var grid_screen: Node3D = $"Van/Van Model/GridScreen"

var van_grid_loc: Vector2
var van_global_loc: Vector2
var van_dir: String
var city_grid: Node2D
var van: Node2D
var action_ui : Control
var player_last_pos: Transform3D
var screen_view_active: bool = false
var target_position: Vector3
var target_rotation: Vector3
var is_camera_lerping: bool = false
var lerp_rotation: bool = false

var turn_ended : bool = false

func _ready() -> void:
	get_tree().paused = false
	GlobalSignals.grid_screen_pressed.connect(_on_grid_screen_pressed)
	city_grid = grid_screen.find_child("City_Grid")
	van = city_grid.find_child("Van")
	van.is_not_moving.connect(check_end_of_path)
	var ui = city_grid.find_child("UI")
	action_ui = ui.find_child("ActionsUI")
	
func _process(delta: float) -> void:
	if is_camera_lerping:
		player.position = player.position.lerp(target_position, camera_lerp_speed * delta)
		if lerp_rotation:
			player.rotation = player.rotation.lerp(target_rotation, camera_lerp_speed * delta)
		
		var pos_done = player.position.distance_to(target_position) < 0.01
		
		if pos_done:
			player.position = target_position
			if lerp_rotation:
				player.rotation = target_rotation
			is_camera_lerping = false
	
func check_end_of_path():
	var status_grid = city_grid.status_effects
	GlobalLocations.van_grid_loc = status_grid.local_to_map(van.position)
	if GlobalLocations.van_grid_loc == GlobalLocations.turn_end_coords:
		print("end this MF turn")
		turn_ended = true
		action_ui.process_turn()
	
func _on_grid_screen_pressed() -> void:
	check_end_of_path()
	if turn_ended:
		get_van_loc()
		var cur_storm_locs = get_storm_locs()
		GlobalLocations.storm_locs = cur_storm_locs
		get_sensors()
		get_fires_floods()
		DirectionList.directions.clear()
		player.make_mouse_visible()
		get_tree().change_scene_to_file("res://City_Grid/city_grid.tscn")
	else:
		if !screen_view_active:
			player_last_pos = player.transform
			target_position = Vector3(-0.53, 2.2, 1.0)
			target_rotation = Vector3.ZERO
			lerp_rotation = true
			player.find_child("CenterContainer").find_child("Crosshair").visible = false
			player.set_physics_process(false)
			screen_view_active = true
			is_camera_lerping = true
		else:
			target_position = player_last_pos.origin
			lerp_rotation = false
			player.find_child("CenterContainer").find_child("Crosshair").visible = true
			player.set_physics_process(true)
			screen_view_active = false
			is_camera_lerping = true
		
	
func get_van_loc():
	#Grabbing Van Location and shit
	van_grid_loc = city_grid.get_van_grid_coords()
	van_global_loc = van.global_position
	if van.direction_copy.back() == null:
		van_dir = city_grid.find_child("ActionsUI").current_van_direction
	else:
		van_dir = van.direction_copy.back().move_direction
	#clear the copy just to avoid anything growing
	van.direction_copy.clear()
	GlobalLocations.current_turn += 1
	GlobalLocations.van_grid_loc = van_grid_loc
	GlobalLocations.van_global_loc = van_global_loc
	GlobalLocations.van_global_dir = van_dir

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
	GlobalLocations.cur_storm_count = storms_array.size()
	return storms_array
	
func get_sensors():
	var tilemap = city_grid.status_effects
	var sensor_array = tilemap.get_used_cells_by_id(0,Vector2(4,0))
	GlobalLocations.sensor_locs = sensor_array
	var level_sensors = city_grid.sensors_total
	var sens_col = level_sensors - sensor_array.size()
	GlobalLocations.sensors_collected = sens_col
	
