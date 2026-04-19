extends Node

@onready var card_slot = preload("res://scenes/card_slot.tscn")
var all_chats = {}
var available_chats = []

# All Card data
var all_cards = {}
# Current Deck
var current_deck = {}
# Cards Available for Deck
var cards_available = {}
var card_manager_path : String = "res://data/gwj92 - Card Brewing.json"

# Load JSON Data
func load_json_data_from_path():
	var file_string = FileAccess.get_file_as_string(card_manager_path)
	var json_data
	if file_string !=null:
		json_data = JSON.parse_string(file_string)
		print("JSON loaded successfully")
	else:
		print("JSON not loaded successfully")
	
	if json_data == null:
		print("JSON data null")
	
	return json_data
