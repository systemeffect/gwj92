extends Node2D

@export var storm_scene : PackedScene

@onready var actions_ui: Control = $UI/ActionsUI
@onready var van: Node2D = $Van
@onready var current_turn_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/CurrentTurnLabel
@onready var move_in_progress: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/MoveInProgress
@onready var actions_queued_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/ActionsQueued

@onready var grid_overlay: TextureRect = $UI/GridOverlay
@onready var city_grid: TileMapLayer = $GridArea/Tilemaps/CityGrid

# Movement Preview Lines
@onready var queue_preview: Line2D = $UI/PathPreview/QueuePreview
@onready var preview_collider: CollisionShape2D = $UI/PathPreview/PreviewCollider
@onready var preview_cont: Area2D = $UI/PathPreview/PreviewCont

# Storm
@onready var storms_container: Node2D = $StormsContainer



var current_turn : int = 0
var turn_in_progress : bool = false
var movement_in_progress : bool = false
var actions_queued : int = 0
var action_queue : Array
var current_preview_coords : Vector2
var current_preview_position : Vector2

# Van positions
var van_position : Vector2
var van_grid_coords : Vector2
var van_start_pos: Vector2

# Storm variables
var wind_direction : Direction

func _ready() -> void:
	actions_ui.round_initiated.connect(_on_round_initiated)
	actions_ui.move_test.connect(_on_move_test_pressed)
	actions_ui.action_queued.connect(_on_action_queued)
	actions_ui.action_removed.connect(_on_action_removed)
	actions_ui.reset_queue.connect(_on_reset_queue)
	actions_ui.reset_van.connect(_on_reset_van)
	
	action_queue = actions_ui.current_queue
	current_turn_label.text = "Current turn: " + str(current_turn)
	
	van.is_moving.connect(_on_van_is_moving)
	van.is_not_moving.connect(_on_van_is_not_moving)
	
	van_position = van.global_position
	van_start_pos = van.global_position
	van_grid_coords = city_grid.local_to_map(van_position)
	print(van_grid_coords)
	current_preview_coords = van_grid_coords
	current_preview_position = van_position

func _on_reset_queue():
	queue_preview.clear_points()

func _on_action_queued(card_id : String):
	actions_queued_label.text = "Actions queued: " + str(action_queue.size())
	find_path()

func find_path():
	var last_point = van_grid_coords
	var new_point = last_point
	queue_preview.clear_points()
	queue_preview.add_point(van_position)
	clear_collider_container()
	for move in action_queue:
		var card = Util.all_cards[str(move)]
		var move_amt = int(card.get("MOVE_AMOUNT"))
		var move_dir = card.get("MOVE_DIRECTION")
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
	
# Needs to be rebuilt
func _on_round_initiated(moves : Array):
	while moves.size() > 0:
		var current_move = moves.pop_front()
		var card = Util.all_cards[current_move]
		if card != null:
			actions_ui.highlight_active_slot(current_turn)
			
			var move_dir = card.get("MOVE_DIRECTION")
			var move_amt = card.get("MOVE_AMOUNT")
			print("move direction: " + move_dir + " and move amt: " + str(move_amt))
			van.move(move_dir, move_amt)
			await get_tree().create_timer(2.0).timeout
			print("timer timeout!")
			current_turn +=1
			current_turn_label.text = "Current turn: " + str(current_turn)
		else:
			print("card is null")

func set_wind_direction(dir : Direction):
	wind_direction = dir
	# emit signal if needed?


func _on_move_test_pressed() -> void:
	van.move("RIGHT", 3)
	pass # Replace with function body.

func _on_reset_van() -> void:
	if movement_in_progress:
		return
	else:
		van.position = van_start_pos


func _on_show_grid_pressed() -> void:
	if grid_overlay.visible:
		grid_overlay.hide()
	else:
		grid_overlay.show()


func _on_preview_cont_body_entered(body: Node2D) -> void:
	print("body entered!")
	pass # Replace with function body.


func _on_brew_storm_pressed() -> void:
	var current_pos = van.position
	var storm = storm_scene.instantiate()
	storm.origin_pos = current_pos
	storms_container.add_child(storm)
	pass # Replace with function body.


func _on_add_status_pressed() -> void:
	var first_storm = storms_container.get_child(0)
	var storm_loc = first_storm.position
	print("STATUS AT " + str(storm_loc))
	pass # Replace with function body.
