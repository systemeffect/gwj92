extends Node2D

@export var storm_scene : PackedScene
@export var sensor_collider : PackedScene

@onready var actions_ui: Control = $UI/ActionsUI
@onready var van: Node2D = $Van
@onready var sensor_collect: Sprite2D = $Van/SensorCollect
@onready var collect_animate: AnimationPlayer = $Van/CollectAnimate
@onready var status_log_label: RichTextLabel = $UI/ActionsUI/StatusLogLabel



@onready var current_turn_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/CurrentTurnLabel
@onready var move_in_progress: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/MoveInProgress
@onready var actions_queued_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/ActionsQueued
@onready var wind_dir: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/WindDir

@onready var grid_overlay: TextureRect = $UI/GridOverlay
@onready var city_grid: TileMapLayer = $GridArea/Tilemaps/CityGrid
@onready var status_effects: TileMapLayer = $GridArea/Tilemaps/StatusEffects

# Movement Preview Lines
@onready var queue_preview: Line2D = $UI/PathPreview/QueuePreview
@onready var preview_collider: CollisionShape2D = $UI/PathPreview/PreviewCollider
@onready var preview_cont: Area2D = $UI/PathPreview/PreviewCont

# Storm
@onready var storms_container: Node2D = $StormsContainer
@onready var wind_timer: Timer = $WindTimer
var change_wind : bool = true

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

# Storm variables
var wind_direction : Direction

func _ready() -> void:
	get_tree().paused = true
	actions_ui.round_initiated.connect(_on_round_initiated)
	actions_ui.action_queued.connect(_on_action_queued)
	actions_ui.action_removed.connect(_on_action_removed)
	actions_ui.reset_queue.connect(_on_reset_queue)
	actions_ui.reset_movement_queue.connect(_on_reset_movement_queue)
	actions_ui.movement_queued.connect(_on_movement_queued)
	actions_ui.end_of_turn.connect(update_map_interface)
	action_queue = actions_ui.current_queue
	status_effects.update_status_log.connect(_on_update_status_log)
	movement_queue = actions_ui.current_movement_queue
	#turn_num.text = str(current_turn)
	
	
	van.is_moving.connect(_on_van_is_moving)
	van.is_not_moving.connect(_on_van_is_not_moving)
	
	van_position = van.global_position
	van_start_pos = van.global_position
	van_grid_coords = city_grid.local_to_map(van_position)
	print(van_grid_coords)
	current_preview_coords = van_grid_coords
	current_preview_position = van_position
	
	if GlobalLocations.van_grid_loc != Vector2(0, 0):
		van_grid_coords = GlobalLocations.van_grid_loc
	
	if GlobalLocations.van_global_loc != Vector2(0,0):
		van.global_position = GlobalLocations.van_global_loc
		
	fire_status = Status.new()
	fire_status.status_name = "fire"
	fire_status.status_type = 1
	fire_status.status_amount = 3
	flood_status = Status.new()
	flood_status.status_name = "flood"
	flood_status.status_type = 2
	flood_status.status_amount = 3
	wind_status = Status.new()
	wind_status.status_name = "wind"
	wind_status.status_type = 3
	wind_status.status_amount = 3
	sensor_collect.hide()


func _process(delta: float) -> void:
	if end_of_turn:
		check_end_of_movement()
		
func check_end_of_movement():
	if van.is_not_moving:
		actions_ui.process_turn()

func update_map_interface(attr_array : Array):
		_on_spread_pressed(attr_array)
		end_of_turn = false

func _on_reset_queue():
	# reset wind preview line at end (if applies)
	pass

func _on_action_queued(card_id : String):
	actions_queued_label.text = "Actions queued: " + str(action_queue.size())
	#find_path()

func _on_movement_queued():
	print("movement queued")
	find_path()
	
func _on_reset_movement_queue():
	queue_preview.clear_points()
	queue_preview.add_point(van_position)

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
		if preview_cont.has_overlapping_bodies():
			print("collision!")
		
func clear_collider_container():
	while preview_cont.get_child_count() > 0:
		var child = preview_cont.get_child(0)
		preview_cont.remove_child(child)
		child.queue_free()

func _on_action_removed(current_queue : Array):
	actions_queued = action_queue.size()
	actions_queued_label.text = "Actions queued: " + str(actions_queued)
	find_path()

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
	var dir_array = DirectionList.directions.duplicate()

	while dir_array.size() > 0:
		var current_move = dir_array.pop_front()

		if current_move != null:
			var move_dir = current_move.move_direction
			var move_amt = current_move.move_amount

			van.move(move_dir, move_amt)
			await van.is_not_moving

			current_turn += 1
			current_turn_label.text = "Current turn: " + str(current_turn)
			turn_in_progress = true
		else:
			print("card is null")
	if dir_array.size() == 0:
		end_of_turn = true
	

func set_wind_direction(dir : Direction):
	wind_direction = dir
	# emit signal if needed?


func _on_show_grid_pressed() -> void:
	if grid_overlay.visible:
		grid_overlay.hide()
	else:
		grid_overlay.show()


func _on_preview_cont_body_entered(body: Node2D) -> void:
	print("body entered!")


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
			wind_direction.move_direction = "NONE"
			wind_dir.text = "WindDir: calm"
	var storms = storms_container.get_children()
	for storm in storms:
		storm.set_storm_direction(wind_direction)
	change_wind = false
	wind_timer.start()
		
func get_van_grid_coords() -> Vector2:
	return van_grid_coords

#func set_sensor_collisions():
	#var sensor_array = status_effects.get_sensor_zones()
	#for sensor in sensor_array:
		#var new_collider = sensor_collider.instantiate()
		#new_collider.global_position = sensor.global_position
		#sensors.add_child(new_collider)
	

func _on_area_2d_area_entered(area: Area2D) -> void:
	# triggered when van and storm colliders meet
	# signal to trigger van shake+sound/storm fx
	if area.name == "StormArea":
		status_log_label.update_text("WARNING: Proximity to STORM EVENT might cause damage to the vehicle. Exercise caution.")

func _on_update_status_log(status : Status):
	var type = status.status_type
	var amt = status.status_amount
	status_log_label.update_text(str(amt) + " " + str(type) + " brew-charges expended...")

func _on_wind_timer_timeout() -> void:
	_on_change_wind_pressed()
	

func _on_spread_pressed(attr_array : Array) -> void:
	var statuses = []
	for attr in attr_array:
		if attr.spawns_fire:
			fire_status.status_amount = attr.attr_value
			statuses.append(fire_status)
		if attr.spawns_flood:
			flood_status.status_amount = attr.attr_value
			statuses.append(flood_status)
		if attr.spawns_wind:
			wind_status.status_amount = attr.attr_value
			# store/trigger wind
	for status in statuses:
		var cur_status = statuses.pop_front()
		status_effects.spread_available_cell(cur_status)
		#_on_add_status_pressed()
		var storms = storms_container.get_children()
		for storm in storms:
			var storm_loc = storm.position
			storm_loc = city_grid.local_to_map(storm_loc)
			
			#status_type.init_coord = storm_loc
			status_effects.add_status_effect(cur_status, storm_loc)


func _on_area_2d_body_entered(body: Node2D) -> void:
	# Triggers when van hits a status tile (fire, sensor,...)
	var pos = van.position
	var grid = status_effects.local_to_map(pos)
	var cell_atlas : Vector2 = status_effects.get_cell_atlas_coords(grid)
	match cell_atlas:
		Vector2(2,0):
			take_damage()
			# trigger fire damage?
			pass
		Vector2(3,0):
			# trigger flood effect
			take_damage()
			pass
		Vector2(4,0):
			#increment sensor collected
			collect_sensor(grid)
	print("STATUS TILE CROSSED")

func collect_sensor(grid : Vector2):
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
		# queue death/round end
		print("You dead. This is where the game/round would end")
	
