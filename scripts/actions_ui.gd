extends Control

signal round_initiated
signal move_test
signal action_queued
signal action_removed
signal reset_queue
signal reset_van

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

# Action Queue
var queue_size : int = 0
var max_queue_size : int = 4
var current_queue : Array
var queue_item_1 : Dictionary
var queue_item_2 : Dictionary
var queue_item_3 : Dictionary
var queue_item_4 : Dictionary

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
var test_hand : Array[String]= ["3", "7","11","19", "15", "21"]

var van : Node2D
var van_grid_coords : Vector2

func _ready() -> void:
	load_card_data()
	current_deck = test_hand
	available_cards = current_deck
	load_cards()


# JSON functions
func load_card_data():
	var json_data = Util.load_json_data_from_path()
	if json_data != null:
		#load regular data
		#var cards = json_data.get("IMPORT")
		#load test data
		var cards = json_data.get("Halves_Import")
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
	card_attributes["MOVE_DIRECTION"] = json_data.get("MOVE_DIRECTION")
	card_attributes["MOVE_AMOUNT"] = json_data.get("MOVE_AMOUNT")
	card_attributes["CARD_DESCRIPTION"] = json_data.get("CARD_DESCRIPTION")
	card_attributes["CARD_ICON"] = json_data.get("CARD_ICON")
	card_attributes["STORM_TYPE"] = json_data.get("STORM_TYPE")
	card_attributes["STORM_VALUE"] = json_data.get("STORM_VALUE")
	
	return card_attributes
	
func get_card_by_id(card_id: String) -> Dictionary:
	if all_cards.has(card_id):
		return all_cards[card_id]
	else:
		print("CARD ID NOT FOUND")
		return {}

# Load cards, current_deck version - want to switch to available cards
#func load_cards():
	#if current_deck != null:
		#cur_deck_size = 0
		#for card_id in current_deck:
			#print("Checking if card_id exists in current_deck")
			#var slot = Util.card_slot.instantiate()
			#grid_container.add_child(slot)
			#if all_cards.has(card_id):
				#slot.set_card(all_cards[card_id])
				#print("Slot created for " + str(card_id))
				#cur_deck_size += 1
				#slot.pressed.connect(_on_pressed.bind(card_id))
			#else:
				#slot.set_empty()

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
	# Packages the current queue dictionaries and sends it to the game manager
	#var queue_dict_array : Array[Dictionary]
	#queue_dict_array.append(queue_item_1)
	#queue_dict_array.append(queue_item_2)
	#queue_dict_array.append(queue_item_3)
	#queue_dict_array.append(queue_item_4)
	if queue_size > 0:
		
		round_initiated.emit(current_queue)

func _on_move_test_pressed() -> void:
	move_test.emit()

func _on_reset_van_pressed() -> void:
	reset_van.emit()

func _on_van_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")
