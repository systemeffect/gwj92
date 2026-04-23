extends Node3D

@export var player: CharacterBody3D
@export var camera_lerp_speed: float = 5.0
@export var van_model: Node3D
@export var target_position: Vector3
@export var target_rotation: Vector3
@onready var grid_screen: Node3D = $"Van/Van Model/GridScreen"
@onready var camera_pivot: Node3D = player.find_child("CameraPivot")
@onready var settings_menu: CenterContainer = $UI/SettingsMenu

var van_grid_loc: Vector2
var van_global_loc: Vector2
var van_dir: String
var city_grid: Node2D
var van: Node2D
var action_ui : Control
var status_effects : TileMapLayer
var player_last_pos: Transform3D
var screen_view_active: bool = false
var is_camera_lerping: bool = false
var lerp_rotation: bool = false
var last_van_body_transform: Transform3D
var default_target_position: Vector3
var default_target_rotation: Vector3
var pivot_last_x_rotation: float = 0.0

var turn_ended : bool = false

func _ready() -> void:
	turn_ended = false
	get_tree().paused = false
	GlobalSignals.grid_screen_pressed.connect(_on_grid_screen_pressed)
	GlobalSignals.escape_key.connect(_on_escape_key_pressed)
	city_grid = grid_screen.find_child("City_Grid")
	van = city_grid.find_child("Van")
	van.route_finished.connect(_on_van_route_finished)
	var gridarea = city_grid.find_child("GridArea")
	var tilemaps = gridarea.find_child("Tilemaps")
	status_effects = tilemaps.find_child("StatusEffects")
	var ui = city_grid.find_child("UI")
	action_ui = ui.find_child("ActionsUI")
	print("DirectionList Movement Queue: ", DirectionList.movement_queue)
	action_ui.current_movement_queue.append_array(DirectionList.movement_queue)
	print("Action UI Movement Queue: ", action_ui.current_movement_queue)
	action_ui.update_movement_queue()
	last_van_body_transform = van_model.global_transform
	default_target_position = target_position
	default_target_rotation = target_rotation
	
func _process(delta: float) -> void:
	if is_camera_lerping:
		player.position = player.position.lerp(target_position, camera_lerp_speed * delta)
		camera_pivot.rotation.x = lerp_angle(camera_pivot.rotation.x, 0.0, camera_lerp_speed * delta)
		if lerp_rotation:
			player.rotation = player.rotation.lerp(target_rotation, camera_lerp_speed * delta)
		
		var pos_done = player.position.distance_to(target_position) < 0.01

		if pos_done:
			player.position = target_position
			if lerp_rotation:
				player.rotation = target_rotation
			is_camera_lerping = false
	
	# While screen view is active, follow the van body's animation movement
	if screen_view_active and !is_camera_lerping:
		var current_van_transform = van_model.global_transform
		var delta_transform = current_van_transform * last_van_body_transform.affine_inverse()
		player.global_transform = delta_transform * player.global_transform
		last_van_body_transform = current_van_transform
	else:
		last_van_body_transform = van_model.global_transform
		
func check_end_of_path() -> void:
	call_deferred("_check_end_of_path_deferred")

func _check_end_of_path_deferred() -> void:
	var current_cell: Vector2i = get_van_grid_cell()
	var end_cell: Vector2i = Vector2i(GlobalLocations.turn_end_coords)
	GlobalLocations.van_grid_loc = current_cell
	print("current:", current_cell, " end:", end_cell, " directions:", DirectionList.directions.size(), " moving:", van.is_currently_moving)
	if current_cell == end_cell and !van.is_currently_moving:
		turn_ended = true
		action_ui.process_turn()
	else:
		turn_ended = false
		
func can_exit_to_city_grid() -> bool:
	var current_cell: Vector2i = get_van_grid_cell()
	var end_cell: Vector2i = Vector2i(GlobalLocations.turn_end_coords)
	return (
		!van.is_currently_moving
		and DirectionList.directions.size() <= 0
		and current_cell == end_cell
	)

func get_van_grid_cell() -> Vector2i:
	var movement_grid: TileMapLayer = city_grid.city_grid
	var local_pos := movement_grid.to_local(van.global_position)
	return movement_grid.local_to_map(local_pos)

func _on_grid_screen_pressed() -> void:
	#if turn_ended:
		#get_van_loc()
		#var cur_storm_locs = get_storm_locs()
		#GlobalLocations.storm_locs = cur_storm_locs
		#GlobalLocations.current_queue.clear()
		#get_sensors()
		#get_fires_floods()
		#GlobalLocations.van_integrity = van.integrity
		#DirectionList.directions.clear()
		#DirectionList.movement_queue.clear()
		#player.make_mouse_visible()
		#if AudioManager.sfx_engine_idle.playing:
			#AudioManager.sfx_engine_idle.stop()
		#get_tree().change_scene_to_file("res://City_Grid/city_grid.tscn")
	#else:
	if !screen_view_active:
		player_last_pos = player.global_transform
		pivot_last_x_rotation = camera_pivot.rotation.x
		target_position = default_target_position
		target_rotation = default_target_rotation
		lerp_rotation = true
		camera_pivot.rotation.x = 0.0
		player.find_child("CenterContainer").find_child("Crosshair").visible = false
		#player.set_physics_process(false)
		screen_view_active = true
		is_camera_lerping = true
		last_van_body_transform = van_model.global_transform
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#else:
		#player_leave_screen()

func get_van_loc():
	#Grabbing Van Location and shit
	van_grid_loc = status_effects.local_to_map(van.global_position)
	van_global_loc = van.global_position
	if van.direction_copy.is_empty():
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
	
func _on_van_route_finished() -> void:
	turn_ended = true
	Util.end_of_turn = true
	action_ui.process_turn()

func _on_escape_key_pressed() -> void:
	if settings_menu.visible == false:
		if !screen_view_active and !is_camera_lerping:
			settings_menu.show()
	else:
		settings_menu.hide()

func player_leave_screen() -> void:
	target_position = player_last_pos.origin
	lerp_rotation = false
	player.find_child("CenterContainer").find_child("Crosshair").visible = true
	player.set_physics_process(true)
	screen_view_active = false
	is_camera_lerping = true
