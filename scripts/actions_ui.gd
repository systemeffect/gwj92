extends Control

signal round_initiated
signal movement_queued
signal reset_movement_queue
signal action_queued
signal action_removed
signal reset_queue
signal end_of_turn
signal extraction

@export_enum("NORTH", "EAST", "SOUTH", "WEST") var current_van_direction : String

@onready var move_button: Button = $ActionDebug/VBoxContainer/MovementButtons/Move
@onready var van_button: Button = $ActionDebug/VBoxContainer/MovementButtons/VanButton

@onready var end_of_turn_prompt: PanelContainer = $EndOfTurnPrompt
@onready var end_of_turn_prompt_2d: PanelContainer = $EndOfTurnPrompt2D
@onready var end_of_turn_prompt_2: PanelContainer = $EndOfTurnPrompt2

# Resource panel labels
@onready var turn_num: Label = $ResourcesPanel/Margin/TopBar/Turn/TurnNum
@onready var integrity_num: Label = $ResourcesPanel/Margin/TopBar/Resources/Column2/IntegrityNum
@onready var sensors_num: Label = $ResourcesPanel/Margin/TopBar/Resources/Column2/SensorsNum

@onready var status_log_label: RichTextLabel = $StatusLogLabel
@onready var cur_fire_attr: Label = $ActionQueue/VBox/HBox/CurFireAttr
@onready var cur_flood_attr: Label = $ActionQueue/VBox/HBox/CurFloodAttr
@onready var cur_wind_attr: Label = $ActionQueue/VBox/HBox/CurWindAttr


# Stormbrew/Action Queue
@onready var grid_container: GridContainer = $PanelContainer/GridContainer
@onready var queue_grid_container: GridContainer = $ActionQueue/VBox/GridContainer


# Action Queue Slots
@onready var action_1: Control = $ActionQueue/VBox/GridContainer/Action_1
@onready var action_2: Control = $ActionQueue/VBox/GridContainer/Action_2
@onready var action_3: Control = $ActionQueue/VBox/GridContainer/Action_3

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
var flood_attr : int = 0
var wind_attr : int = 0
var fire_attr : int = 0
var queue_item_1 : Attribute
var queue_item_2 : Attribute
var queue_item_3 : Attribute
var nullify_set : bool = false

var cur_deck_size : int = 0
var selected_card : String
var selected_action : String

var cur_sensors : int = 0

var json_file_path = "res://data/gwj92 - Card Brewing.json"
# All available CARDS/ACTIONS in the game
var all_cards = {}
# Card IDs for all cards currently in the deck
var current_deck : Array[String] = ["0","1","2","3","4","5","6","7","8","9","10","11"]
# Card IDs for all cards currently available to use as actions
var available_cards : Array[String]
var test_hand : Array[String]= ["3", "7","11","4", "9", "0"]

var van : Node2D
var van_grid_coords : Vector2

func _init() -> void:
	set_turn_hand()
	
func _ready() -> void:
	if GlobalLocations.van_global_dir != "":
		current_van_direction = GlobalLocations.van_global_dir
	load_card_data()
	current_deck = ["0","1","2","3","4","5","6","7","8","9","10","11"]
	current_queue = GlobalLocations.current_queue
	print(current_deck)
	load_cards()
	set_van_direction_index()
	set_integrity(GlobalLocations.van_integrity)
	cur_sensors = GlobalLocations.sensors_collected
	
	
func _process(delta: float) -> void:
	if queue_size == 3 and moves_selected == 3:
		move_button.disabled = false
		van_button.disabled = false
	else:
		move_button.disabled = true
		van_button.disabled = true

func process_turn():
	#get_tree().paused = true
	end_of_turn_prompt_2.show()
	

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

func get_attr_by_id(card_id: String) -> Attribute:
	var card = get_card_by_id(card_id)
	var type = card.get("ATTRIBUTE_TYPE")
	var value = card.get("VALUE")
	var new_attr = Attribute.new()
	new_attr.set_attribute(type, value)
	return new_attr
	
func get_card_by_id(card_id: String) -> Dictionary:
	if all_cards.has(card_id):
		return all_cards[card_id]
	else:
		print("CARD ID NOT FOUND")
		return {}

# Load cards available_cards version
func load_cards():
		if available_cards.size() > 6:
			available_cards.resize(6)
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

func set_turn_hand():
	available_cards.clear()
	if current_deck != null:
		cur_deck_size = 0
		print("cur deck size " + str(cur_deck_size))
		while cur_deck_size < 6:
			var draw_card = current_deck.pick_random()
			if !available_cards.has(draw_card):
				available_cards.append(draw_card)
				cur_deck_size += 1
		print(available_cards)
	available_cards.resize(6)

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

	queue_item_1 = null
	queue_item_2 = null
	queue_item_3 = null
	fire_attr = 0
	flood_attr = 0
	wind_attr = 0
	reset_attr_labels()

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
					queue_item_1 = get_attr_by_id(card_id)
					update_cur_attr(queue_item_1)
				1:
					action_2.set_card(card_data)
					action_2.pressed.connect(_on_pressed.bind(card_id))
					queue_item_2 = get_attr_by_id(card_id)
					update_cur_attr(queue_item_2)
				2:
					action_3.set_card(card_data)
					action_3.pressed.connect(_on_pressed.bind(card_id))
					queue_item_3 = get_attr_by_id(card_id)
					update_cur_attr(queue_item_3)
			slot += 1

func update_cur_attr(attr : Attribute):
	if attr.spawns_fire:
		fire_attr += attr.attr_value
	if attr.spawns_flood:
		flood_attr += attr.attr_value
	if attr.spawns_wind:
		wind_attr += attr.attr_value
	reset_attr_labels()
	
func reset_attr_labels():
	cur_fire_attr.text = "Fire: " + str(fire_attr)
	cur_flood_attr.text = "flood: " + str(flood_attr)
	cur_wind_attr.text = "wind: " + str(wind_attr)

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
	match slot:
		0:
			action_1.set_active_border_color()
		1:
			action_2.set_active_border_color()
		2:
			action_3.set_active_border_color()


func _on_reset_queue_pressed() -> void:
	available_cards.append_array(current_queue)
	clear_grid_container()
	load_cards()
	current_queue.clear()
	queue_size = 0
	clear_queue_window()
	reset_queue.emit()

func _on_pressed(card_id: String):
	if current_queue.has(card_id):
		AudioManager.ui_cancel.play()
		#remove from queue
		if card_id != "":
			current_queue.erase(card_id)
			available_cards.append(card_id)
			selected_action = ""
			print(current_queue.size())
			queue_size -= 1
			action_removed.emit(current_queue)
			_on_deck_updated()
			clear_queue_window()
			update_queue()
	else:
		AudioManager.ui_storm.play()
		if card_id != "":
			print(str(card_id))
			if queue_size < max_queue_size:
				current_queue.append(card_id)
				action_queued.emit(card_id)
				queue_size += 1
				var card_index = available_cards.find(card_id, 0)
				available_cards.remove_at(card_index)
				#Util remove script
				_on_deck_updated()
				clear_queue_window()
				update_queue()
				selected_card = ""
			else:
				print("Action Queue Full")
	
	# Checks to see if the selected card is in the action queue
	if current_queue.has(card_id):
		# If so, deselect available cards
		if selected_action != card_id:
			selected_action = card_id
			selected_card = ""
			deselect_avail()
		else:
			selected_action = ""
	else:
		if selected_card != card_id:
			#if the selected card is in the available grid, deselect action queue
			selected_card = card_id
			selected_action = ""
			deselect_queue()
		else:
			selected_card = ""

func _on_move_pressed() -> void:
	var parent = find_parent("Level")
	if parent == null:
		status_log_label.update_text("[SETTING AUTODRIVE PATH]")
	if moves_selected > 0:
		AudioManager.ui_preview.play()
		build_preview_directions()
		for d in DirectionList.previewer_directions:
			status_log_label.update_text("Direction: " + str(d.move_direction) + " | Amount: " + str(d.move_amount))
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
	AudioManager.ui_rollout.play()
	var result = MovementPlanner.build_directions(current_movement_queue, current_van_direction, Util.all_cards)
	DirectionList.directions.clear()
	DirectionList.directions.append_array(result["directions"])
	GlobalLocations.van_global_dir = result["final_facing"]
	GlobalLocations.current_queue = current_queue
	GlobalLocations.status_log = status_log_label.text
	GlobalLocations.cur_fire_attr = fire_attr
	GlobalLocations.cur_flood_attr = flood_attr
	GlobalLocations.cur_wind_attr = wind_attr
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/level.tscn")


func _on_reset_moves_pressed() -> void:
	AudioManager.ui_reset.play()
	current_movement_queue.clear()
	moves_selected = 0
	clear_movement_queue_window()
	reset_movement_queue.emit()
	van_direction_index = van_direction_index_default
	set_van_direction_string()

func _on_forward_1_pressed() -> void:
	if moves_selected < max_move_queue_size:
		AudioManager.ui_click.play()
		current_movement_queue.append("12")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_forward_2_pressed() -> void:
	if moves_selected < max_move_queue_size:
		AudioManager.ui_click.play()
		current_movement_queue.append("13")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_reverse_1_pressed() -> void:
	if moves_selected < max_move_queue_size:
		AudioManager.ui_click.play()
		current_movement_queue.append("14")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_turn_left_pressed() -> void:
	if moves_selected < max_move_queue_size:
		AudioManager.ui_click.play()
		current_movement_queue.append("15")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_turn_around_pressed() -> void:
	if moves_selected < max_move_queue_size:
		AudioManager.ui_click.play()
		current_movement_queue.append("17")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()

func _on_turn_right_pressed() -> void:
	if moves_selected < max_move_queue_size:
		AudioManager.ui_click.play()
		current_movement_queue.append("16")
		build_preview_directions()
		
		moves_selected += 1
		clear_movement_queue_window()
		update_movement_queue()
		movement_queued.emit()


func _on_end_of_turn_button_pressed() -> void:
	available_cards = []
	clear_grid_container()
	set_turn_hand()
	var attr_array = set_attribute_status_array()
	end_of_turn.emit(attr_array)
	reset_movement_queue.emit()
	_on_reset_queue_pressed()
	_on_reset_moves_pressed()

	end_of_turn_prompt_2d.hide()

func set_attribute_status_array() -> Array:
	var attribute_array = []
	for card in current_queue:
		var attr_type = all_cards[card].get("ATTRIBUTE_TYPE")
		var attr_value = all_cards[card].get("VALUE")
		var new_attribute = Attribute.new()
		new_attribute.set_attribute(attr_type, attr_value)
		attribute_array.append(new_attribute)
	return attribute_array

func set_integrity(new_int : int):
	match new_int:
		0:
			integrity_num.text = "0%"
		1:
			integrity_num.text = "33%"
		2:
			integrity_num.text = "66%"
		3:
			integrity_num.text = "100%"

func collect_sensor():
	cur_sensors = GlobalLocations.sensors_collected
	AudioManager.sfx_sensor_pickup.play()
	sensors_num.text = str(cur_sensors)


func _on_extraction_button_pressed() -> void:
	extraction.emit()
