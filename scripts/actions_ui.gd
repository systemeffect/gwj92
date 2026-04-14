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
var action_slot_count = 4 # calculate this from container API?
@onready var action_1: Control = $ActionQueue/GridContainer/Action_1
@onready var action_2: Control = $ActionQueue/GridContainer/Action_2
@onready var action_3: Control = $ActionQueue/GridContainer/Action_3
@onready var action_4: Control = $ActionQueue/GridContainer/Action_4

# Action Queue
var current_queue: CardQueue = CardQueue.new()
var cur_deck_size : int = 0
var selected_card : Card
var selected_action : Card

var json_file_path = "res://data/gwj92 - Card Brewing.json"
# All available CARDS/ACTIONS in the game
var all_cards: Array[Card] = []
# Card IDs for all cards currently in the deck
var current_deck: Array[Card] = []
# Card IDs for all cards currently available to use as actions
var available_cards : Array[Card] = []
var test_hand : Array[String]= ["3", "7","11","19", "15", "21"]
var default_card: Card = Card.new("-1", {
	"CARD_TYPE": "",
	"MOVE_DIRECTION": "",
	"MOVE_AMOUNT": 0.0,
	"CARD_DESCRIPTION": "",
	"CARD_ICON": "",
	"STORM_TYPE": "",
	"STORM_VALUE": 0
})

var van : Node2D
var van_grid_coords : Vector2

func _ready() -> void:
	load_card_data()
	for card in all_cards:
		if test_hand.has(card.id):
			current_deck.append(card)
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
					all_cards.append(Card.new(card_id, cards[card_id]))
	Util.all_cards = all_cards
	
func get_card_by_id(card_id: String) -> Card:
	for card in all_cards:
		if card.id == card_id:
			return card
	print("CARD ID NOT FOUND")
	return default_card

# Load cards available_cards version
func load_cards():
	cur_deck_size = 0
	for card in available_cards:
		var slot = Util.card_slot.instantiate()
		grid_container.add_child(slot)
		slot.set_card(card)
		print("Slot created for " + card.id)
		cur_deck_size += 1
		slot.pressed.connect(_on_pressed.bind(card))

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
	for card in current_queue:
		available_cards.append(card)
	clear_grid_container()
	load_cards()
	current_queue.clear()
	clear_queue_window()
	reset_queue.emit()

func _on_pressed(card: Card):
	# Checks to see if the selected card is in the action queue
	if current_queue.has(card):
		# If so, deselect available cards
		if !is_instance_valid(selected_action) || selected_action.id != card.id:
			selected_action = card
			sel_act.text = "SelAct: " + selected_action.id + " - " + selected_action.description
			selected_card = null
			sel_card.text = "SelCard: "
			deselect_avail()
		else:
			selected_action = null
			sel_act.text = "SelAct: "
	else:
		if !is_instance_valid(selected_card) || selected_card.id != card.id:
			#if the selected card is in the available grid, deselect action queue
			selected_card = card
			sel_card.text = "SelCard: " + selected_card.id
			selected_action = null
			sel_act.text = "SelAct: "
			deselect_queue()
		else:
			selected_card = null
			sel_card.text = "SelCard: "

# Adding/removing actions to the queue
func _on_add_action_button_pressed():
	if is_instance_valid(selected_card):
		print("add action pressed")
		print(str(selected_card))
		if current_queue.size() >= action_slot_count:
			return
		current_queue.enqueue(selected_card)
		action_queued.emit()
		var action
		match current_queue.size():
			1: action = action_1
			2: action = action_2
			3: action = action_3
			4: action = action_4
		action.set_card(selected_card)
		action.pressed.connect(_on_pressed.bind(selected_card))		
		current_queue_debug.text += str(selected_card.id) + " \n"
		var card_index = available_cards.find(selected_card, 0)
		available_cards.remove_at(card_index)		
		_on_deck_updated()
		selected_card = null
		sel_card.text = "SelCard: "
	
func _on_remove_action_button_pressed() -> void:
	#action_removed.emit(selected_card)
	if is_instance_valid(selected_action):
		print("erasing " + str(selected_action))
		current_queue.erase(selected_action)
		available_cards.append(selected_action)
		selected_action = null
		sel_act.text = "SelAct: "
		print(current_queue.size())
		action_removed.emit(current_queue)
		_on_deck_updated()
		clear_queue_window()

func _on_move_pressed() -> void:
	# Packages the current queue dictionaries and sends it to the game manager
	for card in current_queue:
		var move_dir = card.direction
		var move_amt = card.amount
		
		var new_direction = Direction.new()
		new_direction.move_direction = move_dir
		new_direction.move_amount = move_amt
		DirectionList.directions.append(new_direction)
	
	print("DIRECTIONSSSSSSS ", DirectionList.directions)
	round_initiated.emit(current_queue)

func _on_move_test_pressed() -> void:
	move_test.emit()

func _on_reset_van_pressed() -> void:
	reset_van.emit()

func _on_van_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/level.tscn")
