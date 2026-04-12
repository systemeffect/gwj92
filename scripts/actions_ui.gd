extends Control

signal action_queued
signal action_removed

@onready var grid_container: GridContainer = $PanelContainer/GridContainer

var cur_deck_size : int = 0
var selected_card : String

var json_file_path = "res://data/gwj92 - Card Brewing.json"
# All available CARDS/ACTIONS in the game
var all_cards = {}
# Card IDs for all cards currently in the deck
var current_deck : Array[String]
# Card IDs for all cards currently available
var avail_cards = []
var test_hand : Array[String]= ["3", "7", "15", "17"]

func _ready() -> void:
	load_card_data()
	current_deck = test_hand
	load_cards()
	
func load_card_data():
	var json_data = Util.load_json_data_from_path()
	if json_data != null:
		var cards = json_data.get("IMPORT")
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
	
	return card_attributes
	
func get_card_by_id(card_id: String) -> Dictionary:
	if all_cards.has(card_id):
		return all_cards[card_id]
	else:
		print("CARD ID NOT FOUND")
		return {}
		
func load_cards():
	if current_deck != null:
		cur_deck_size = 0
		for card_id in current_deck:
			print("Checking if card_id exists in current_deck")
			var slot = Util.card_slot.instantiate()
			grid_container.add_child(slot)
			if all_cards.has(card_id):
				slot.set_card(all_cards[card_id])
				print("Slot created for " + str(card_id))
				cur_deck_size += 1
				slot.pressed.connect(_on_pressed.bind(card_id))
			else:
				slot.set_empty()
				
func _on_pressed(card_id: String):
	if selected_card != card_id:
		selected_card = card_id
	else:
		selected_card = ""


func _on_add_action_button_pressed() -> void:
	action_queued.emit(selected_card)



func _on_remove_action_button_pressed() -> void:
	action_removed.emit(selected_card)
