extends Node

@onready var card_slot = preload("res://scenes/card_slot.tscn")

enum TILE_TYPE { FIRE, FLOOD, SENSOR, OBSTACLE}
var fire_atlas = Vector2(2,0)
var flood_atlas = Vector2(3,0)
var sensor_atlas = Vector2(4,0)
var obstacle_atlas = Vector2(5,0)

var current_level_index : int = 1

var all_chats = {}
var available_chats = []

# All Card data
var all_cards = {}
# Current Deck
var current_deck = {}
# Cards Available for Deck
var cards_available = {}
var card_manager_path : String = "res://data/gwj92 - Card Brewing.json"

var end_of_turn : bool = false
var wind_push : Direction

var planning_stage : bool

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
