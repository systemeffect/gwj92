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

@onready var end_of_turn_prompt_2d: PanelContainer = $UI/ActionsUI/EndOfTurnPrompt2D
@onready var end_of_round: PanelContainer = $UI/ActionsUI/EndOfRound


@onready var current_turn_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/CurrentTurnLabel
@onready var move_in_progress: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/MoveInProgress
@onready var actions_queued_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/ActionsQueued
@onready var wind_dir: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/WindDir
@onready var wind_label: Label = $UI/ActionsUI/ResourcesPanel/Margin/TopBar/Turn/WindLabel

@onready var grid_overlay: TextureRect = $UI/GridOverlay
@onready var city_grid: TileMapLayer = $GridArea/Tilemaps/CityGrid
@onready var status_effects: TileMapLayer = $GridArea/Tilemaps/StatusEffects

# Movement Preview Lines
@onready var queue_preview: Line2D = $UI/PathPreview/QueuePreview
@onready var preview_collider: CollisionShape2D = $UI/PathPreview/PreviewCollider
@onready var preview_cont: Area2D = $UI/PathPreview/PreviewCont
var turn_end_coords : Vector2

# Storm
@onready var storms_container: Node2D = $StormsContainer
@onready var wind_timer: Timer = $WindTimer
var wind_speed : int
var change_wind : bool = true
var storm_locs

var fire_status = Status
var flood_status = Status
var wind_status = Status

var current_turn : int = 0
var end_of_turn : bool = false
var turn_in_progress : bool = false
var movement_in_progress : bool = false
var moves_queued : int = 0
var movement_queue : Array
var actions_queued : int = 0
var action_queue : Array
var current_preview_coords : Vector2
var current_preview_position : Vector2

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

func _ready() -> void:
	var parent_node = find_parent("Level")
	if parent_node == null:
		if AudioManager.music_planning.playing == false:
			AudioManager.music_planning.play()
		AudioManager.music_menu.stop()
		AudioManager.music_execute_1.stop()
		AudioManager.music_execute_2.stop()
		AudioManager.music_execute_3.stop()
	get_tree().paused = true
	actions_ui.round_initiated.connect(_on_round_initiated)
	actions_ui.reset_movement_queue.connect(_on_reset_movement_queue)
	actions_ui.movement_queued.connect(_on_movement_queued)
	actions_ui.end_of_turn.connect(update_map_interface)
	actions_ui.extraction.connect(_on_round_end)
	action_queue = actions_ui.current_queue
	status_effects.update_status_log.connect(_on_update_status_log)
	movement_queue = actions_ui.current_movement_queue
	current_turn = GlobalLocations.current_turn
	turn_num.text = str(current_turn)
	
	van.is_moving.connect(_on_van_is_moving)
	van.is_not_moving.connect(_on_van_is_not_moving)
	
	# Restore saved van state first
	if GlobalLocations.van_grid_loc != Vector2(0, 0):
		van_grid_coords = GlobalLocations.van_grid_loc
	
	if GlobalLocations.van_global_loc != Vector2(0, 0):
		van.global_position = GlobalLocations.van_global_loc
	
	# Now cache the scene-entry position for preview resets
	van_position = van.global_position
	van_start_pos = van.global_position
	van_grid_coords = city_grid.local_to_map(van_position)
	van_starting_anim = animated_sprite_2d.animation
	
	print(van_grid_coords)
	
	current_preview_coords = van_grid_coords
	current_preview_position = van_position
	
	if GlobalLocations.current_turn > 0:
		var storms_array = GlobalLocations.storm_locs
		load_storms(storms_array)
		var fires_array = GlobalLocations.fire_locs
		var floods_array = GlobalLocations.flood_locs
		load_fires_floods(fires_array, floods_array)
		var parent = find_parent("Level")
		if parent == null:
			end_of_turn_prompt_2d.show()
		status_log_label.text = GlobalLocations.status_log
		
	van.integrity = GlobalLocations.van_integrity
	var cur_sensors = status_effects.get_used_cells_by_id(0, Vector2(4,0))
	
	#sensors_collected = sensors_total - cur_sensors.size()
	set_sensors()
	sensors_collected = GlobalLocations.sensors_collected
	if sensors_collected == sensors_total:
		_on_round_end()
	if GlobalLocations.current_turn > 0:
		status_log_label.text = GlobalLocations.status_log
		
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

func _process(delta: float) -> void:
	#check_end_of_path()
	if end_of_turn:
		check_end_of_movement()

func check_end_of_movement():
	if van.is_not_moving:
		get_tree().paused = true
		var parent = find_parent("Level")
		if parent != null:
			actions_ui.process_turn()


func update_map_interface(attr_array : Array):
	_on_change_wind_pressed()
	_on_spread_pressed(attr_array)
	var fire_array = status_effects.get_used_cells_by_id(0,Vector2(2,0))
	var flood_array = status_effects.get_used_cells_by_id(0, Vector2(3,0))
	GlobalLocations.fire_locs = fire_array
	GlobalLocations.flood_locs = flood_array
	end_of_turn = false

func load_fires_floods(fires : Array, floods : Array):
	for fire in fires:
		status_effects.set_cell(fire, 0, Vector2(2,0))
	for flood in floods:
		status_effects.set_cell(flood, 0, Vector2(3,0))

func _on_movement_queued():
	print("movement queued")
	find_path()
	
func _on_reset_movement_queue():
	queue_preview.clear_points()
	queue_preview.add_point(van_position)
	clear_collider_container()
	if DirectionList.previewer_directions.size() <= 0 or DirectionList.previewer_directions.size() > 0:
		reset_preview_van()

func find_path():
	var last_point: Vector2 = city_grid.local_to_map(van.global_position)
	var new_point = last_point
	queue_preview.clear_points()
	queue_preview.add_point(van.global_position)
	clear_collider_container()
	var dir_array = DirectionList.previewer_directions
	print('finding path')
	print("moves in queue: " + str(dir_array.size()))
	for move in dir_array:
		var move_amt = move.move_amount
		var move_dir = move.move_direction
		var move_vector : Vector2
		match move_dir:
			"NORTH":
				move_vector = Vector2(0, -move_amt)
			"EAST":
				move_vector = Vector2(move_amt, 0)
			"SOUTH":
				move_vector = Vector2(0, move_amt)
			"WEST":
				move_vector = Vector2(-move_amt, 0)
		new_point = last_point + move_vector
		queue_preview.add_point(city_grid.map_to_local(new_point))
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
	turn_end_coords = last_point
	GlobalLocations.turn_end_coords = turn_end_coords
		
func clear_collider_container():
	while preview_cont.get_child_count() > 0:
		var child = preview_cont.get_child(0)
		preview_cont.remove_child(child)
		child.queue_free()

func _on_van_is_moving():
	movement_in_progress = true
	move_in_progress.text = "Move in Progress: true"
	
func _on_van_is_not_moving():
	movement_in_progress = false
	move_in_progress.text = "Move in Progress: false"
	
	van_grid_coords = city_grid.local_to_map(van.global_position)
	
# Needs to be rebuilt
func _on_round_initiated():
	get_tree().paused = false
	reset_preview_van()
	var dir_array = DirectionList.previewer_directions.duplicate()
	while dir_array.size() > 0:
		var current_move = dir_array.pop_front()
		if current_move != null:
			var move_dir = current_move.move_direction
			var move_amt = current_move.move_amount
			van.move(move_dir, move_amt)
			await van.is_not_moving
		else:
			print("card is null")
	end_of_turn = true
	turn_num.text = str(current_turn)
	turn_in_progress = true

func set_wind_direction(dir : Direction):
	wind_direction = dir
	var direction = wind_direction.move_direction
	direction = direction.to_upper()
	wind_label.text = "WIND: " + direction
	# emit signal if needed?

func load_storms(locs : Array):
	if locs.size() > 0:
		print("loadin storms")
		var all_locs = locs
		var storms = storms_container.get_children()
		for storm in storms:
			var loc = all_locs.pop_front()
			storm.set_origin(loc)
			#
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
		


func _on_show_grid_pressed() -> void:
	if grid_overlay.visible:
		grid_overlay.hide()
	else:
		grid_overlay.show()

func _on_brew_storm_pressed() -> void:
	var current_pos = van.position
	var storm = storm_scene.instantiate()
	storm.origin_pos = current_pos
	storms_container.add_child(storm)

func _on_add_status_pressed() -> void:
	var statuses = []
	statuses.append(fire_status)
	statuses.append(flood_status)
	var random = statuses.pick_random()
	status_effects.spread_available_cell(random)
	#_on_add_status_pressed()
	var storms = storms_container.get_children()
	for storm in storms:
		var storm_loc = storm.position
		storm_loc = city_grid.local_to_map(storm_loc)
		
		#status_type.init_coord = storm_loc
		status_effects.add_status_effect(random, storm_loc)

func _on_change_wind_pressed() -> void:
	wind_direction = Direction.new()
	var ran = randi_range(0,4)
	match ran:
		0:
			wind_direction.move_direction = "NORTH"
			wind_dir.text = "WindDir: ^N^"
		1:
			wind_direction.move_direction = "EAST"
			wind_dir.text = "WindDir: >E>" 
		2:
			wind_direction.move_direction = "SOUTH"
			wind_dir.text = "WindDir: vSv" 
		3:
			wind_direction.move_direction = "WEST"
			wind_dir.text = "WindDir: <W<"
		4:
			wind_direction.move_direction = "CALM"
			wind_dir.text = "WindDir: calm"
	wind_label.text = "WIND: " + wind_direction.move_direction
	var storms = storms_container.get_children()
	for storm in storms:
		storm.set_storm_direction(wind_direction)
	change_wind = false
	var wind = GlobalLocations.cur_wind_attr
	status_log_label.update_text("Detecting change in Wind Speed!")
	var speed : float = snapped(wind * randf_range(24.6,36.2), 0.1)
	await get_tree().create_timer(0.6).timeout
	status_log_label.update_text("Gusts up to " + str(speed) + " MPH...")
		
func get_van_grid_coords() -> Vector2:
	return van_grid_coords


func _on_area_2d_area_entered(area: Area2D) -> void:
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


func _on_spread_pressed(attr_array : Array) -> void:
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
			#status_type.init_coord = storm_loc
		status_effects.add_status_effect(cur_status, storm_loc)
		storm.set_storm_speed(wind_attr)
		storm.dropped_status(cur_status)
	
	if fire_attr > 0:
		fire_status.status_amount = fire_attr
		status_effects.spread_available_cell(fire_status)
	if flood_attr > 0:
		flood_status.status_amount = flood_attr
		status_effects.spread_available_cell(flood_status)

func _on_area_2d_body_entered(body: Node2D) -> void:
	# Triggers when van hits a status tile (fire, sensor,...)
	var pos = van.position
	var grid = status_effects.local_to_map(pos)
	var cell_atlas : Vector2 = status_effects.get_cell_atlas_coords(grid)
	match cell_atlas:
		Vector2(2,0):
			take_damage()
			status_log_label.update_text("Fire damage - van integrity weakened...")
			# trigger fire damage?
			pass
		Vector2(3,0):
			# trigger flood effect
			#take_damage()
			status_log_label.update_text("Flooded area, new storm brewed by the TEMPEST Drive!")
			create_storms(pos, 1)
			pass
		Vector2(4,0):
			#increment sensor collected
			var ran = randi_range(189, 69420)
			status_log_label.update_text("Sensor data gathered! " + str(ran) + " anomalies detected!")
			collect_sensor(grid)
	print("STATUS TILE CROSSED")

func collect_sensor(grid : Vector2):
	var parent = find_parent("Level")
	if parent != null:
		status_effects.set_cell(grid,0,Vector2(1,0))
		actions_ui.collect_sensor()
	sensor_collect.show()
	collect_animate.play("collect_sensor")
	await collect_animate.animation_finished
	sensor_collect.hide()
	print("SENSOR COLLECTED")
	
func take_damage():
	var new_integrity = van.take_damage()
	actions_ui.set_integrity(new_integrity)
	print("taking damage here!")
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
		print("You dead. This is where the game/round would end")
	
func _on_preview_cont_area_entered(area: Area2D) -> void:
	if area.name == "Boundaries":
		status_log_label.update_text("Path Out of Bounds, resetting autodrive...")

#func _on_update_wind_speed(wind: int):
	#status_log_label.update_text("Detecting change in Wind Speed!")
	#var speed : float = wind * 31.8
	#await get_tree().create_timer(0.6).timeout
	#status_log_label.update_text("Gusts up to " + str(speed) + " MPH...")

func set_sensors():
	if current_turn > 0:
		sensors_collected = GlobalLocations.sensors_collected
		var sensor_locs = GlobalLocations.sensor_locs
		var cur_sensor_locs = status_effects.get_used_cells_by_id(0,Vector2(4,0))
		for loc in sensor_locs:
			if cur_sensor_locs.has(loc):
				cur_sensor_locs.erase(loc)
		for loc in cur_sensor_locs:
			status_effects.set_cell(loc,0,Vector2(1,0))
			var parent = find_parent("Level")
			if parent == null:
				pass
			#	GlobalLocations.sensors_collected += 1
				actions_ui.collect_sensor()

func _on_signal_events_area_entered(area: Area2D) -> void:
	print("TRIGGER SIGNAL")
	pass # Replace with function body.

func reset_preview_van() -> void:
	van.global_position = van_start_pos
	van.target_loc_x = van.global_position.x
	van.target_loc_y = van.global_position.y
	van.current_axis = ""
	van.is_turning = false
	van.turn_direction = "none"
	van.is_currently_moving = false
	animated_sprite_2d.animation = van_starting_anim
	
	current_turn = 0
	turn_in_progress = false
	end_of_turn = false

func _on_round_end():
	end_of_round.show()
	end_of_turn_prompt_2d.hide()
	end_of_round.set_final_score()
	pass
