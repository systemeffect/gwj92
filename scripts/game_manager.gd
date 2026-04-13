extends Node2D

@onready var actions_ui: Control = $UI/ActionsUI
@onready var van: Node2D = $Van
@onready var current_turn_label: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/CurrentTurnLabel
@onready var move_in_progress: Label = $UI/Debug/Margin/PanelContainer/DebugMenu/MoveInProgress


var current_turn : int = 0
var turn_in_progress : bool = false
var movement_in_progress : bool = false
var clicked = false
var van_start_pos: Vector2

func _ready() -> void:
	actions_ui.round_initiated.connect(_on_round_initiated)
	actions_ui.move_test.connect(_on_move_test_pressed)
	actions_ui.van_reset.connect(_on_van_reset_pressed)
	
	current_turn_label.text = "Current turn: " + str(current_turn)
	van_start_pos = van.position
	
	van.is_moving.connect(_on_van_is_moving)
	van.is_not_moving.connect(_on_van_is_not_moving)
	
func _on_van_is_moving():
	movement_in_progress = true
	move_in_progress.text = "Move in Progress: true"
	
func _on_van_is_not_moving():
	movement_in_progress = false
	move_in_progress.text = "Move in Progress: false"
	
	
func _on_round_initiated(moves : Array):
	while moves.size() > 0:
		var current_move = moves.pop_front()
		var card = Util.all_cards[current_move]
		if card != null:
			actions_ui.highlight_active_slot(current_turn)
			
			var move_dir = card.get("MOVE_DIRECTION")
			var move_amt = card.get("MOVE_AMOUNT")

			var new_direction = Direction.new()
			new_direction.move_direction = move_dir
			new_direction.move_amount = move_amt
			DirectionList.directions.append(new_direction)
			print("THIS IS DIRECTIONLIST: ", DirectionList.directions)
			
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
	van.move("EAST", 3)
	var new_direction = Direction.new()
	new_direction.move_direction = "EAST"
	new_direction.move_amount = 3
	DirectionList.directions.append(new_direction)
	print("THIS IS DIRECTIONLIST: ", DirectionList.directions)
	pass # Replace with function body.
	
func _on_van_reset_pressed() -> void:
	van.position = van_start_pos
