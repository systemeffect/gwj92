extends Node2D

@onready var actions_ui: Control = $UI/ActionsUI
@onready var van: Node2D = $Van
@onready var current_turn_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/CurrentTurnLabel
@onready var move_in_progress: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/MoveInProgress
@onready var actions_queued_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/ActionsQueued

@onready var grid_overlay: TextureRect = $UI/GridOverlay
@onready var city_grid: TileMapLayer = $GridArea/Tilemaps/CityGrid

# Movement Preview Lines
@onready var queue_preview: Line2D = $UI/PathPreview/QueuePreview



var current_turn : int = 0
var turn_in_progress : bool = false
var movement_in_progress : bool = false
var actions_queued : int = 0
var action_queue : Array
var current_preview_coords : Vector2
var current_preview_position : Vector2

var van_position : Vector2
var van_grid_coords : Vector2

func _ready() -> void:
	actions_ui.round_initiated.connect(_on_round_initiated)
	actions_ui.move_test.connect(_on_move_test_pressed)
	actions_ui.action_queued.connect(_on_action_queued)
	actions_ui.action_removed.connect(_on_action_removed)
	actions_ui.reset_queue.connect(_on_reset_queue)
	action_queue = actions_ui.current_queue
	current_turn_label.text = "Current turn: " + str(current_turn)
	
	van.is_moving.connect(_on_van_is_moving)
	van.is_not_moving.connect(_on_van_is_not_moving)
	
	van_position = van.global_position
	van_grid_coords = city_grid.local_to_map(van_position)
	print(van_grid_coords)
	current_preview_coords = van_grid_coords
	current_preview_position = van_position

func _on_reset_queue():
	queue_preview.clear_points()

func _on_action_queued(card_id : String):
	actions_queued_label.text = "Actions queued: " + str(action_queue.size())
	find_path()
	#var card = Util.all_cards[card_id]
	#var move_amt = int(card.get("MOVE_AMOUNT"))
	#var move_dir = card.get("MOVE_DIRECTION")
	#var move_vector : Vector2
	#match move_dir:
		#"NORTH":
			#move_vector = Vector2(0, -move_amt)
		#"EAST":
			#move_vector = Vector2(move_amt, 0)
		#"SOUTH":
			#move_vector = Vector2(0, move_amt)
		#"WEST":
			#move_vector = Vector2(-move_amt, 0)
	#current_preview_coords += move_vector
	#current_preview_position = city_grid.map_to_local(current_preview_coords)
	#if actions_queued <= 1:
		## when an action is queued, draw a line from the previous move position point
		#queue_preview_1.add_point(van_position)
		#queue_preview_1.add_point(current_preview_position)
		#preview_1_pos = current_preview_position
	#elif actions_queued == 2:
		#queue_preview_2.add_point(preview_1_pos)
		#queue_preview_2.add_point(current_preview_position)
		#preview_2_pos = current_preview_position
	#elif actions_queued == 3:
		#queue_preview_3.add_point(preview_2_pos)
		#queue_preview_3.add_point(current_preview_position)
		#preview_3_pos = current_preview_position
	#elif actions_queued == 4:
		#queue_preview_4.add_point(preview_3_pos)
		#queue_preview_4.add_point(current_preview_position)
		#preview_4_pos = current_preview_position

func find_path():
	var last_point = van_grid_coords
	queue_preview.clear_points()
	queue_preview.add_point(van_position)
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
		last_point += move_vector
		queue_preview.add_point(city_grid.map_to_local(last_point))
		

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

#func _on_round_initiated(moves : Array):
	#while moves.size() > 0:
		#var current_move = moves.pop_front()
		#var card = Util.all_cards[current_move]
		#if card != null:
			#var move_dir = card.get("MOVE_DIRECTION")
			#var move_amt = card.get("MOVE_AMOUNT")
			#print("move direction: " + move_dir + " and move amt: " + str(move_amt))
			#van.move(move_dir, move_amt)
			#await get_tree().create_timer(2.0).timeout
			#print("timer timeout!")
		#else:
			#print("card is null")


func _on_move_test_pressed() -> void:
	van.move("RIGHT", 3)
	pass # Replace with function body.


func _on_show_grid_pressed() -> void:
	if grid_overlay.visible:
		grid_overlay.hide()
	else:
		grid_overlay.show()
