extends Node2D

@export var storm_scene : PackedScene
@export var sensor_collider : PackedScene

@onready var actions_ui: Control = $UI/ActionsUI
@onready var van: Node2D = $Van
@onready var animated_sprite_2d: AnimatedSprite2D = $Van/AnimatedSprite2D
@onready var sensor_collect: Sprite2D = $Van/SensorCollect
@onready var collect_animate: AnimationPlayer = $Van/CollectAnimate
@onready var status_log_label: RichTextLabel = $UI/ActionsUI/StatusLogLabel
@onready var turn_num: Label = $UI/ActionsUI/ResourcesPanel/Margin/TopBar/Turn/TurnNum

@onready var end_of_turn_prompt_2d: Panel = $UI/ActionsUI/EndOfTurnPrompt2D
@onready var end_of_round: PanelContainer = $UI/ActionsUI/EndOfRound

@onready var wind_label: Label = $UI/ActionsUI/ResourcesPanel/Margin/TopBar/Turn/WindLabel

@onready var city_grid: TileMapLayer = $GridArea/Tilemaps/CityGrid
@onready var status_effects: TileMapLayer = $GridArea/Tilemaps/StatusEffects

# Movement Preview Lines
@onready var queue_preview: Line2D = $UI/PathPreview/QueuePreview
@onready var wind_preview: Line2D = $UI/PathPreview/WindPreview
@onready var preview_collider: CollisionShape2D = $UI/PathPreview/PreviewCollider
@onready var preview_cont: Area2D = $UI/PathPreview/PreviewCont
var turn_end_coords : Vector2

# Storm
@onready var storms_container: Node2D = $StormsContainer
@onready var wind_timer: Timer = $WindTimer
var wind_speed : int

var fire_status = Status
var flood_status = Status
var wind_status = Status
var current_level_obstacles : Array
var current_level_index : int = 1

var current_turn : int = 0
var end_of_turn : bool = false
var current_preview_coords : Vector2
var current_preview_position : Vector2
var movement_path_points : Array

var grid_size = Vector2(12,12)
# Van positions
var van_position : Vector2
var van_grid_coords : Vector2
var van_start_pos: Vector2
var van_starting_anim: String

var sensors_total : int = 5
var sensors_collected : int = 0

# Storm variables
var wind_direction : Direction
var wind_push : Direction
var wind_preview_start : Vector2
var wind_preview_end : Vector2

func _ready() -> void:
	AudioManager.music_menu.stop()

	if AudioManager.music_execute_1.playing == false and AudioManager.music_execute_2.playing == false and AudioManager.music_execute_3.playing == false:
		AudioManager.music_planning.play()
	AudioManager.music_menu.stop()
	get_tree().paused = true
	
	# Connecting all the signals
	actions_ui.round_initiated.connect(_on_round_initiated)
	actions_ui.reset_movement_queue.connect(_on_reset_movement_queue)
	actions_ui.movement_queued.connect(_on_movement_queued)
	actions_ui.end_of_turn.connect(update_map_interface)
	actions_ui.extraction.connect(_on_round_end)
	actions_ui.attribute_queued.connect(_on_attribute_queued)
	actions_ui.attribute_unqueued.connect(_on_attribute_unqueued)
	status_effects.update_status_log.connect(_on_update_status_log)
	status_effects.load_storms.connect(set_level_storms)
	#van.is_moving.connect(_on_van_is_moving)
	van.is_not_moving.connect(_on_van_is_not_moving)
	van.move_initiated.connect(_on_move_initiated)
	
	if GlobalLocations.current_turn < 1:
		var index = Util.current_level_index
		status_effects.set_level(index)
		GlobalLocations.current_turn += 1
	
	# Set current turn and current level
	current_turn = GlobalLocations.current_turn
	turn_num.text = str(current_turn)
	# for level loading testing
	
	
	# Setting Van properties/positions
	if GlobalLocations.van_global_loc != Vector2(0, 0):
		van.global_position = GlobalLocations.van_global_loc
	if GlobalLocations.van_global_dir != "":
		animated_sprite_2d.animation = GlobalLocations.van_global_dir
	# Now cache the scene-entry position for preview resets
	van_position = van.global_position
	van_start_pos = van.global_position
	van_grid_coords = city_grid.local_to_map(van_position)
	van_starting_anim = animated_sprite_2d.animation
	van.integrity = GlobalLocations.van_integrity
	turn_end_coords = van_grid_coords
	
	# Preview line settings
	current_preview_coords = van_grid_coords
	current_preview_position = van_position
	

	# Run after the first turn
	#if GlobalLocations.current_turn > 1:
		## This line added to try to fix the stuck-between-tiles issue
		##van.position = city_grid.map_to_local(van_grid_coords)
		#var storms_array = GlobalLocations.storm_locs
		#load_storms(storms_array)
		#var fires_array = GlobalLocations.fire_locs
		#var floods_array = GlobalLocations.flood_locs
		#load_fires_floods(fires_array, floods_array)
		##end_of_turn_prompt_2d.show()
		#status_log_label.text = GlobalLocations.status_log
	##else:
		##var index = Util.current_level_index
		##status_effects.set_level(index)
	#get_obstacle_coords()
	#set_sensors()
	#sensors_collected = GlobalLocations.sensors_collected
	#if sensors_collected == sensors_total:
		#_on_round_end()

	# Set default statuses
	fire_status = Status.new()
	fire_status.status_name = "fire"
	fire_status.status_type = 1
	fire_status.status_amount = 0
	flood_status = Status.new()
	flood_status.status_name = "flood"
	flood_status.status_type = 2
	flood_status.status_amount = 0
	wind_status = Status.new()
	wind_status.status_name = "wind"
	wind_status.status_type = 3
	wind_status.status_amount = 0
	sensor_collect.hide()

func _process(_delta: float) -> void:
	if sensors_collected == sensors_total:
		_on_round_end()
	elif Util.end_of_turn:
		check_end_of_movement()

func set_turn():
	var storms_array = GlobalLocations.storm_locs
	load_storms(storms_array)
	var fires_array = GlobalLocations.fire_locs
	var floods_array = GlobalLocations.flood_locs
	load_fires_floods(fires_array, floods_array)
	status_log_label.text = GlobalLocations.status_log
	get_obstacle_coords()
	set_sensors()
	if GlobalLocations.van_global_dir != "":
		animated_sprite_2d.animation = GlobalLocations.van_global_dir

func check_end_of_movement():
	if !van.is_currently_moving:
		get_tree().paused = true
		actions_ui.process_turn()

func update_map_interface():
	_on_change_wind_pressed()
	_on_spread_pressed()
	var fire_array = status_effects.get_used_cells_by_id(0,Vector2(2,0))
	var flood_array = status_effects.get_used_cells_by_id(0, Vector2(3,0))
	GlobalLocations.fire_locs = fire_array
	GlobalLocations.flood_locs = flood_array
	end_of_turn = false
	GlobalLocations.current_turn += 1
	current_turn = GlobalLocations.current_turn
	set_turn()
	actions_ui.set_turn()

func load_fires_floods(fires : Array, floods : Array):
	for fire in fires:
		status_effects.set_cell(fire, 0, Vector2(2,0))
	for flood in floods:
		status_effects.set_cell(flood, 0, Vector2(3,0))

func _on_movement_queued():
	print("movement queued")
	find_path()
	
func _on_reset_movement_queue():
	turn_end_coords = van_grid_coords
	wind_preview.clear_points()
	preview_wind_push()
	queue_preview.clear_points()
	queue_preview.add_point(van_position)
	clear_collider_container()
	#if DirectionList.previewer_directions.size() <= 0 or DirectionList.previewer_directions.size() > 0:
		#reset_preview_van()

func find_path():
	movement_path_points.clear()
	var last_point: Vector2 = city_grid.local_to_map(van.global_position)
	var new_point = last_point
	movement_path_points.append(last_point)
	queue_preview.clear_points()
	queue_preview.add_point(van.global_position)
	wind_preview.clear_points()
	clear_collider_container()
	var dir_array = DirectionList.previewer_directions
	for move in dir_array:
		var move_amt = move.move_amount
		var move_dir = move.move_direction
		var move_vector : Vector2
		var amt = move_amt
		while amt > 0:
			match move_dir:
				"NORTH":
					move_vector = Vector2(0, -1)
					#move_vector = Vector2(0, -move_amt)
				"EAST":
					move_vector = Vector2(1, 0)
					#move_vector = Vector2(move_amt, 0)
				"SOUTH":
					move_vector = Vector2(0, 1)
					#move_vector = Vector2(0, move_amt)
				"WEST":
					move_vector = Vector2(-1, 0)
					#move_vector = Vector2(-move_amt, 0)
			new_point = last_point + move_vector
			queue_preview.add_point(city_grid.map_to_local(new_point))
			movement_path_points.append(new_point)
			var new_collider = preview_collider.duplicate()
			var new_shape = preview_collider.shape.duplicate()
			new_collider.shape = new_shape
			new_collider.shape.a = city_grid.map_to_local(last_point)
			new_collider.shape.b = city_grid.map_to_local(new_point)
			preview_cont.add_child(new_collider, true)
			last_point = new_point
			# checks to make sure point is in bounds, resets movement if not
			if last_point.x < 0 or last_point.x > 11 or last_point.y < 0 or last_point.y > 11:
				status_log_label.update_text("Path Out of Bounds, resetting autodrive...")
				actions_ui._on_reset_moves_pressed()
				queue_preview.clear_points()
				queue_preview.add_point(van.position)
				clear_collider_container()
			elif current_level_obstacles.has(new_point):
				status_log_label.update_text("Obstruction detected, resetting autodrive...")
				actions_ui._on_reset_moves_pressed()
				queue_preview.clear_points()
				queue_preview.add_point(van.position)
				clear_collider_container()
				break
			amt -= 1
	turn_end_coords = last_point
	GlobalLocations.turn_end_coords = turn_end_coords
	reset_wind_preview()
	preview_wind_push()
		
func preview_wind_push():
	if wind_push != null:
		wind_preview.show()
		var wind_point : Vector2
		wind_point = city_grid.map_to_local(turn_end_coords)
		wind_preview.add_point(wind_point)
		wind_preview_start = wind_point
		var move_vector : Vector2
		match wind_push.move_direction:
			"NORTH":
				move_vector = Vector2(0, -wind_push.move_amount)
			"EAST":
				move_vector = Vector2(wind_push.move_amount, 0)
			"SOUTH":
				move_vector = Vector2(0, wind_push.move_amount)
			"WEST":
				move_vector = Vector2(-wind_push.move_amount, 0)
		var new_point = turn_end_coords + move_vector
		new_point = city_grid.map_to_local(new_point)
		wind_preview.add_point(new_point)
		wind_preview_end = new_point
	else:
		wind_preview.hide()

func reset_wind_preview():
	wind_preview.clear_points()
	wind_preview_start = Vector2(0,0)
	wind_preview_end = Vector2(0,0)

func clear_collider_container():
	while preview_cont.get_child_count() > 0:
		var child = preview_cont.get_child(0)
		preview_cont.remove_child(child)
		child.queue_free()
	
func get_obstacle_coords():
	var obst_array : Array
	obst_array = status_effects.get_used_cells_by_id(0, Vector2(5,0))
	current_level_obstacles = obst_array
	
func _on_van_is_not_moving():
	van_grid_coords = city_grid.local_to_map(van.global_position)
	
# Needs to be rebuilt
func _on_round_initiated():
	get_tree().paused = false
	#reset_preview_van()
	#var dir_array = DirectionList.previewer_directions.duplicate()
	#var index = 0
	#while dir_array.size() > 0:
		#var current_move = dir_array.pop_front()
		#if current_move != null:
			#actions_ui.highlight_active_slot(index)
			#var move_dir = current_move.move_direction
			#var move_amt = current_move.move_amount
			#van.move(move_dir, move_amt)
			#index += 1
			#await van.is_not_moving
		#else:
			#print("card is null")
	end_of_turn = true
	turn_num.text = str(current_turn)
	van.rollout_initiated()

func set_wind_direction(dir : Direction):
	wind_direction = dir
	var direction = wind_direction.move_direction
	direction = direction.to_upper()
	wind_label.text = "WIND: " + direction

# This function loads the storms saved from the 3D scene back into 2d, can be re-done/cut after merge
func load_storms(locs : Array):
	if locs.size() > 0:
		var all_locs = locs
		var storms = storms_container.get_children()
		storms.resize(locs.size())
		for storm in storms:
			var loc = all_locs.pop_front()
			storm.set_origin(loc)
	else:
		print('no storms to load')

func create_storms(origin: Vector2, amt : int):
	var storms = 0
	while storms < amt:
		var storm = storm_scene.instantiate()
		storm.origin_pos = origin
		storms_container.add_child(storm)
		storms += 1
		
func clear_storms():
	while storms_container.get_child_count() > 0:
		var child = storms_container.get_child(0)
		storms_container.remove_child(child)
		child.queue_free()

func set_level_storms(storms : Array):
	clear_storms()
	if storms != null:
		for storm in storms:
			var grid : Vector2 = str_to_var("Vector2" + storm)
			print(storm)
			create_storms(grid, 1)
	var all_storms = storms_container.get_children()
	for strm in all_storms:
		strm.position = status_effects.map_to_local(strm.origin_pos)

func _on_change_wind_pressed() -> void:
	wind_direction = Direction.new()
	var ran = randi_range(0,4)
	match ran:
		0:
			wind_direction.move_direction = "NORTH"
		1:
			wind_direction.move_direction = "EAST"
		2:
			wind_direction.move_direction = "SOUTH" 
		3:
			wind_direction.move_direction = "WEST"
		4:
			wind_direction.move_direction = "CALM"
	wind_label.text = "WIND: " + wind_direction.move_direction
	var storms = storms_container.get_children()
	for storm in storms:
		storm.set_storm_direction(wind_direction)
	var wind = GlobalLocations.cur_wind_attr
	status_log_label.update_text("Detecting change in Wind Speed!")
	var speed : float = snapped(wind * randf_range(24.6,36.2), 0.1)
	await get_tree().create_timer(0.6).timeout
	status_log_label.update_text("Gusts up to " + str(speed) + " MPH...")
		
func get_van_grid_coords() -> Vector2:
	return van_grid_coords


func _on_van_storm_overlap(area: Area2D) -> void:
	# triggered when van and storm colliders meet
	# signal to trigger van shake+sound/storm fx
	if area.name == "StormArea":
		status_log_label.update_text("WARNING: Proximity to STORM EVENT might cause damage to the vehicle. Exercise caution.")
	elif area.name == "Boundaries":
		print("path out of bounds")

func _on_update_status_log(status : Status):
	var status_name = status.status_name
	var amt = status.status_amount
	status_log_label.update_text(str(amt) + " " + str(status_name) + " brew-charges expended...")


func _on_spread_pressed() -> void:
	var fire_attr = GlobalLocations.cur_fire_attr
	var flood_attr = GlobalLocations.cur_flood_attr
	var wind_attr = GlobalLocations.cur_wind_attr
	wind_speed = wind_attr
	var top_attr_flood : bool
	if flood_attr >= fire_attr:
		top_attr_flood = true
	else:
		top_attr_flood = false
	var storms = storms_container.get_children()
	for storm in storms:
		var storm_loc = storm.position
		storm_loc = city_grid.local_to_map(storm_loc)
		var cur_status : Status
		if top_attr_flood:
			cur_status = flood_status
		else:
			cur_status = fire_status
		status_effects.add_status_effect(cur_status, storm_loc)
		storm.set_storm_speed(wind_attr)
		storm.dropped_status(cur_status)
	
	if fire_attr > 0:
		fire_status.status_amount = fire_attr
		status_effects.spread_available_cell(fire_status)
	if flood_attr > 0:
		flood_status.status_amount = flood_attr
		status_effects.spread_available_cell(flood_status)

func _on_van_status_tile_entered(_body: Node2D) -> void:
	# Triggers when van hits a status tile (fire, sensor,...)
	var pos = van.position
	var grid = status_effects.local_to_map(pos)
	var cell_atlas : Vector2 = status_effects.get_cell_atlas_coords(grid)
	match cell_atlas:
		Vector2(2,0):
			take_damage()
			status_log_label.update_text("Fire damage - van integrity weakened...")
			# Signal to 3D scene to trigger fire lighting/sound
			pass
		Vector2(3,0):
			# Signal to 3D scene to trigger flood lighting/sound
			# Slow van?
			status_log_label.update_text("Flooded area, new storm brewed by the TEMPEST Drive!")
			create_storms(pos, 1)
		Vector2(4,0):
			var ran = randi_range(189, 69420)
			status_log_label.update_text("Sensor data gathered! " + str(ran) + " anomalies detected!")
			collect_sensor(grid)
	print("STATUS TILE CROSSED")

func collect_sensor(grid : Vector2):
	status_effects.set_cell(grid,0,Vector2(1,0))
	actions_ui.collect_sensor()
	sensor_collect.show()
	collect_animate.play("collect_sensor")
	await collect_animate.animation_finished
	sensor_collect.hide()
	
func take_damage():
	var new_integrity = van.take_damage()
	actions_ui.set_integrity(new_integrity)
	if new_integrity < 1:
		GlobalLocations.fire_locs = status_effects.get_used_cells_by_id(0, Vector2(2,0))
		GlobalLocations.flood_locs = status_effects.get_used_cells_by_id(0, Vector2(3,0))
		GlobalLocations.sensor_locs = status_effects.get_used_cells_by_id(0, Vector2(4,0))
		var sensors_left = GlobalLocations.sensor_locs
		var sens_col = sensors_total - sensors_left.size()
		GlobalLocations.sensors_collected = sens_col
		var storm_num = storms_container.get_child_count()
		GlobalLocations.cur_storm_count = storm_num
		GlobalLocations.van_integrity = 0
		_on_round_end()
	
func _on_preview_cont_area_entered(area: Area2D) -> void:
	if area.name == "Boundaries":
		status_log_label.update_text("Path Out of Bounds, resetting autodrive...")

func set_sensors():
	if current_turn > 1:
		get_sensors()
		var sensor_locs = GlobalLocations.sensor_locs
		var cur_sensor_locs = status_effects.get_used_cells_by_id(0,Vector2(4,0))
		for loc in sensor_locs:
			if cur_sensor_locs.has(loc):
				cur_sensor_locs.erase(loc)
		for loc in cur_sensor_locs:
			status_effects.set_cell(loc,0,Vector2(1,0))

func get_sensors():
	var sensor_array = status_effects.get_used_cells_by_id(0,Vector2(4,0))
	GlobalLocations.sensor_locs = sensor_array
	var level_sensors = sensors_total
	var sens_col = level_sensors - sensor_array.size()
	GlobalLocations.sensors_collected = sens_col

func reset_preview_van() -> void:
	van.global_position = van_start_pos
	van.target_loc_x = van.global_position.x
	van.target_loc_y = van.global_position.y
	van.current_axis = ""
	van.is_turning = false
	#van.turn_direction = "none"
	van.is_currently_moving = false
	animated_sprite_2d.animation = van_starting_anim
	
	current_turn = 0
	end_of_turn = false

func _on_round_end():
	AudioManager.music_planning.stop()
	AudioManager.music_execute_1.stop()
	AudioManager.music_execute_2.stop()
	AudioManager.music_execute_3.stop()
	if AudioManager.music_menu.playing == false:
		AudioManager.music_menu.play()
	end_of_round.show()
	end_of_turn_prompt_2d.hide()
	end_of_round.set_final_score()

func _on_move_initiated(index : int):
	actions_ui.highlight_active_slot(index)

# Attribute menu interaction
func _on_attribute_queued(card_id : String):
	var card = Util.all_cards[card_id]
	var attribute = card.get("ATTRIBUTE_TYPE")
	if attribute == "WIND":
		var amt = card.get("VALUE")
		if wind_direction == null:
			wind_direction = Direction.new()
			wind_direction.move_direction = "EAST"
		wind_push = wind_direction
		wind_push.move_amount += amt
		Util.wind_push = wind_push
		wind_preview.clear_points()
		preview_wind_push()
		
func _on_attribute_unqueued(card_id : String):
	var card = Util.all_cards[card_id]
	var attribute = card.get("ATTRIBUTE_TYPE")
	if attribute == "WIND":
		var amt = card.get("VALUE")
		wind_push.move_amount -= amt
		Util.wind_push = wind_push
		wind_preview.clear_points()
		preview_wind_push()
