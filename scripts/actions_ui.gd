extends Control

signal round_initiated
signal movement_queued
signal reset_movement_queue
signal action_queued
signal action_removed
signal reset_queue

@export_enum("NORTH", "EAST", "SOUTH", "WEST") var current_van_direction : String

# Stormbrew/Action Queue
@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var queue_grid_container: GridContainer = $ActionQueue/GridContainer
@onready var current_queue_debug: RichTextLabel = $ActionDebug/VBoxContainer/CurrentQueue
@onready var sel_card: Label = $ActionDebug/VBoxContainer/SelCard
@onready var sel_act: Label = $ActionDebug/VBoxContainer/SelAct
@onready var action_queue: Control = $ActionQueue

# Action Queue Slots
@onready var action_1: Control = $ActionQueue/GridContainer/Action_1
@onready var action_2: Control = $ActionQueue/GridContainer/Action_2
@onready var action_3: Control = $ActionQueue/GridContainer/Action_3
@onready var action_4: Control = $ActionQueue/GridContainer/Action_4

# Movement Queue
@onready var movement_grid_container: GridContainer = $MovementQueue/GridContainer
@onready var move_1: Control = $MovementQueue/GridContainer/Move_1
@onready var move_2: Control = $MovementQueue/GridContainer/Move_2
@onready var move_3: Control = $MovementQueue/GridContainer/Move_3
var moves_selected : int = 0
var max_move_queue_size : int = 3
var current_movement_queue : Array
var movement_queue_item_1 : Dictionary
var movement_queue_item_2 : Dictionary
var movement_queue_item_3 : Dictionary
var van_direction_index : int
var van_direction_index_default : int

# Stormbrew / Action Queue
var queue_size : int = 0
var max_queue_size : int = 3
var current_queue : Array
var queue_item_1 : Dictionary
var queue_item_2 : Dictionary
var queue_item_3 : Dictionary
var queue_item_4 : Dictionary
var nullify_set : bool = false

var cur_deck_size : int = 0
var selected_card : String
var selected_action : String

var json_file_path = "res://data/gwj92 - Card Brewing.json"
# All available CARDS/ACTIONS in the game
var all_cards = {}
# Card IDs for all cards currently in the deck
var current_deck : Array[String]
# Card IDs for all cards currently available to use as actions
var available_cards : Array[String]
var test_hand : Array[String]= ["3", "7","11","4", "15", "0"]

var van : Node2D
var van_grid_coords : Vector2

func _ready() -> void:
	if GlobalLocations.van_global_dir != "":
		current_van_direction = GlobalLocations.van_global_dir
	load_card_data()
	current_deck = test_hand
	available_cards = current_deck
	load_cards()
	set_van_direction_index()
	
#func _process(delta: float) -> void:
	#if queue_size == max_queue_size and !nullify_set:
		#nullify_set = true
		#action_1.toggle_nullify(nullify_set)
		#action_2.toggle_nullify(nullify_set)
		#action_3.toggle_nullify(nullify_set)
	#elif queue_size < max_queue_size and nullify_set:
		#nullify_set = false
		#action_1.toggle_nullify(nullify_set)
		#action_2.toggle_nullify(nullify_set)
		#action_3.toggle_nullify(nullify_set)
		

func set_van_direction_index():
	match current_van_direction:
		"NORTH":
			van_direction_index = 0
			van_direction_index_default = 0
		"EAST":
			van_direction_index = 1
			van_direction_index_default = 1
		"SOUTH":
			van_direction_index = 2
			van_direction_index_default = 2
		"WEST":
			van_direction_index = 3
			van_direction_index_default = 3
func set_van_direction_string():
	match van_direction_index:
		0:
			current_van_direction = "NORTH"
		1:
			current_van_direction = "EAST"
		2:
			current_van_direction = "SOUTH"
		3:
			current_van_direction = "WEST"

# JSON functions
func load_card_data():
	var json_data = Util.load_json_data_from_path()
	if json_data != null:
		#load regular data
		#var cards = json_data.get("IMPORT")
		#load test data
		var cards = json_data.get("Att_Cards_Import")
		if cards != null:
			for i in range(0, cards.size()):
				var card_id = str(i)
				if cards.has(card_id):
					all_cards[card_id] = parse_card_data_from_json(i, cards[card_id])
	Util.all_cards = all_cards

func parse_card_data_from_json(id, json_data : Dictionary):
	#Creates dictionary to hold at card attributes
	var card_attributes = {}
	# Extract all attribute data from json
	card_attributes["ID"] = id
	
	card_attributes["CARD_TYPE"] = json_data.get("CARD_TYPE")
	card_attributes["ATTRIBUTE_TYPE"] = json_data.get("ATTRIBUTE_TYPE")
	card_attributes["VALUE"] = json_data.get("VALUE")
	card_attributes["DESCRIPTION_HEADING"] = json_data.get("DESCRIPTION_HEADING")
	card_attributes["DESCRIPTION_SUBHEADING"] = json_data.get("DESCRIPTION_SUBHEADING")
	card_attributes["STORM_EFFECT"] = json_data.get("STORM_EFFECT")
	card_attributes["CARD_ICON"] = json_data.get("CARD_ICON")
	
	return card_attributes
	
func get_card_by_id(card_id: String) -> Dictionary:
	if all_cards.has(card_id):
		return all_cards[card_id]
	else:
		print("CARD ID NOT FOUND")
		return {}

# Load cards available_cards version
func load_cards():
	if available_cards != null:
		cur_deck_size = 0
		for card_id in available_cards:
			print("Checking if card_id exists in available_cards")
			var slot = Util.card_slot.instantiate()
			grid_container.add_child(slot)
			if all_cards.has(card_id):
				slot.set_card(all_cards[card_id])
				print("Slot created for " + str(card_id))
				cur_deck_size += 1
				slot.pressed.connect(_on_pressed.bind(card_id))
				if queue_size == max_queue_size and !nullify_set:
					nullify_set = true
					slot.toggle_nullify(nullify_set)
				elif queue_size < max_queue_size and nullify_set:
					nullify_set = false
					slot.toggle_nullify(nullify_set)
			else:
				slot.set_empty()

# Deselect functions for each gridcontainer
func deselect_avail():
	var avail_grid = grid_container.get_children()
	for slot in avail_grid:
		slot.deselect()
		
func deselect_queue():
	var queue_grid = queue_grid_container.get_children()
	for slot in queue_grid:
		slot.deselect()

# Available cards - ActionUI
func clear_grid_container():
	print("clearing Deck grid")
	while grid_container.get_child_count() > 0:
		var child = grid_container.get_child(0)
		grid_container.remove_child(child)
		child.queue_free()

func _on_deck_updated():
	clear_grid_container()
	load_cards()

# Action Queue functions
func clear_queue_window():
	action_1.set_empty()
	if action_1.pressed.is_connected(_on_pressed):
		action_1.pressed.disconnect(_on_pressed)
	action_2.set_empty()
	if action_2.pressed.is_connected(_on_pressed):
		action_2.pressed.disconnect(_on_pressed)
	action_3.set_empty()
	if action_3.pressed.is_connected(_on_pressed):
		action_3.pressed.disconnect(_on_pressed)
	action_4.set_empty()
	if action_4.pressed.is_connected(_on_pressed):
		action_4.pressed.disconnect(_on_pressed)
	queue_item_1 = {}
	queue_item_2 = {}
	queue_item_3 = {}
	queue_item_4 = {}

func clear_movement_queue_window():
	move_1.set_empty()
	if move_1.pressed.is_connected(_on_pressed):
		move_1.pressed.disconnect(_on_pressed)
	move_2.set_empty()
	if move_2.pressed.is_connected(_on_pressed):
		move_2.pressed.disconnect(_on_pressed)
	move_3.set_empty()
	if move_3.pressed.is_connected(_on_pressed):
		move_3.pressed.disconnect(_on_pressed)
	movement_queue_item_1 = {}
	movement_queue_item_2 = {}
	movement_queue_item_3 = {}

func update_queue():
	var slot = 0
	for card_id in current_queue:
		if card_id != "":
			var card_data = Util.all_cards[card_id]
			match slot:
				0:
					action_1.set_card(card_data)
					action_1.pressed.connect(_on_pressed.bind(card_id))
					queue_item_1 = card_data
				1:
					action_2.set_card(card_data)
					action_2.pressed.connect(_on_pressed.bind(card_id))
					queue_item_2 = card_data
				2:
					action_3.set_card(card_data)
					action_3.pressed.connect(_on_pressed.bind(card_id))
					queue_item_3 = card_data
				3:
					action_4.set_card(card_data)
					action_4.pressed.connect(_on_pressed.bind(card_id))
					queue_item_4 = card_data
			slot += 1

func update_movement_queue():
	var slot = 0
	for card_id in current_movement_queue:
		if card_id != "":
			var card_data = Util.all_cards[card_id]
			match slot:
				0:
					move_1.set_card(card_data)
					move_1.pressed.connect(_on_pressed.bind(card_id))
					movement_queue_item_1 = card_data
				1:
					move_2.set_card(card_data)
					move_2.pressed.connect(_on_pressed.bind(card_id))
					movement_queue_item_2 = card_data
				2:
					move_3.set_card(card_data)
					move_3.pressed.connect(_on_pressed.bind(card_id))
					movement_queue_item_3 = card_data
			slot += 1

func highlight_active_slot(slot : int):
	action_1.set_default_border_color()
	action_2.set_default_border_color()
	action_3.set_default_border_color()
	action_4.set_default_border_color()
	match slot:
		0:
			action_1.set_active_border_color()
		1:
			action_2.set_active_border_color()
		2:
			action_3.set_active_border_color()
		3:
			action_4.set_active_border_color()

func _on_reset_queue_pressed() -> void:
	available_cards.append_array(current_queue)
	clear_grid_container()
	load_cards()
	current_queue.clear()
	queue_size = 0
	refresh_queue()
	clear_queue_window()
	reset_queue.emit()

func _on_pressed(card_id: String):
	# Checks to see if the selected card is in the action queue
	if current_queue.has(card_id):
		# If so, deselect available cards
		if selected_action != card_id:
			selected_action = card_id
			sel_act.text = "SelAct: " + selected_action
			selected_card = ""
			sel_card.text = "SelCard: " + selected_card
			deselect_avail()
		else:
			selected_action = ""
			sel_act.text = "SelAct: " + selected_action
	else:
		if selected_card != card_id:
			#if the selected card is in the available grid, deselect action queue
			selected_card = card_id
			sel_card.text = "SelCard: " + selected_card
			selected_action = ""
			sel_act.text = "SelAct: " + selected_action
			deselect_queue()
		else:
			selected_card = ""
			sel_card.text = "SelCard: " + selected_card

# Adding/removing actions to the queue
func _on_add_action_button_pressed() -> void:
	if selected_card != "":
		print("add action pressed")
		print(str(selected_card))
		if queue_size < max_queue_size:
			print("room in queue - adding")
			current_queue.append(selected_card)
			refresh_queue()
			action_queued.emit(selected_card)
			queue_size += 1
			var card_index = available_cards.find(selected_card, 0)
			available_cards.remove_at(card_index)
			#Util remove script
			_on_deck_updated()
			clear_queue_window()
			update_queue()
			selected_card = ""
			sel_card.text = "SelCard: " + selected_card
		else:
			print("Action Queue Full")

func refresh_queue():
	current_queue_debug.text = ""
	for action in current_queue:
		current_queue_debug.text += str(action) + " \n"

func _on_remove_action_button_pressed() -> void:
	#action_removed.emit(selected_card)
	if selected_action != "":
		print("erasing " + str(selected_action))
		current_queue.erase(selected_action)
		available_cards.append(selected_action)
		selected_action = ""
		sel_act.text = "SelAct: " + selected_action
		print(current_queue.size())
		refresh_queue()
		queue_size -= 1
		action_removed.emit(current_queue)
		
		_on_deck_updated()
		clear_queue_window()
		update_queue()

func _on_move_pressed() -> void:
	if moves_selected > 0:
		var result = MovementPlanner.build_directions(current_movement_queue, current_van_direction, Util.all_cards)

		DirectionList.directions.clear()
		DirectionList.directions.append_array(result["directions"])
		for d in DirectionList.directions:
			print("Direction:", d.move_direction, "| Amount:", d.move_amount)

		current_van_direction = result["final_facing"]

		round_initiated.emit()
	else:
		print("max moves reached")
		
func build_preview_directions():
	var result = MovementPlanner.build_preview_directions(current_movement_queue, current_van_direction, Util.all_cards)
	DirectionList.previewer_directions.clear()
	DirectionList.previewer_directions.append_array(result["directions"])
	for d in DirectionList.previewer_directions:
		print("Direction:", d.move_direction, "| Amount:", d.move_amount)

		#current_van_direction = result["final_facing"]


func _on_van_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_reset_moves_pressed() -> void:
	current_movement_queue.clear()
	moves_selected = 0
	clear_movement_queue_window()
	reset_movement_queue.emit()
	van_direction_index = van_direction_index_default
	set_van_direction_string()

func _on_forward_1_pressed() -> void:
	if moves_selected < max_move_queue_size:
		current_movement_queue.append("16")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_forward_2_pressed() -> void:
	if moves_selected < max_move_queue_size:
		current_movement_queue.append("17")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_reverse_1_pressed() -> void:
	if moves_selected < max_move_queue_size:
		current_movement_queue.append("18")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_turn_left_pressed() -> void:
	if moves_selected < max_move_queue_size:
		current_movement_queue.append("19")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_turn_around_pressed() -> void:
	if moves_selected < max_move_queue_size:
		current_movement_queue.append("21")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_turn_right_pressed() -> void:
	if moves_selected < max_move_queue_size:
		current_movement_queue.append("20")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()
