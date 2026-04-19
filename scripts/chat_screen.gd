extends Control

@onready var chat_timer: Timer = $ChatTimer
@onready var chat_scroll: RichTextLabel = $Panel/Margin/ChatScroll


var json_file_path = "res://data/gwj92 - Card Brewing.json"

var all_chats = {}
var available_chats = []

func _ready() -> void:
	load_chat_data()
	#available_chats = Util.available_chats
	push_chat()

# JSON functions
func load_chat_data():
	var json_data = Util.load_json_data_from_path()
	if json_data != null:
		var chats = json_data.get("Random_Signals")
		if chats != null:
			for i in range(0, chats.size()):
				var chat_id = str(i)
				if chats.has(chat_id):
					all_chats[chat_id] = parse_chat_data_from_json(i, chats[chat_id])
					available_chats.append(chat_id)
	Util.all_chats = all_chats

func parse_chat_data_from_json(id, json_data : Dictionary):
	#Creates dictionary to hold at card attributes
	var chat_attributes = {}
	# Extract all attribute data from json
	chat_attributes["ID"] = id
	
	chat_attributes["TEXT"] = json_data.get("TEXT")
	chat_attributes["SOURCE"] = json_data.get("SOURCE")
	chat_attributes["PAIR"] = json_data.get("PAIR")
	chat_attributes["PAIR_TEXT"] = json_data.get("PAIR_TEXT")
	chat_attributes["PAIR_SOURCE"] = json_data.get("PAIR_SOURCE")

	
	return chat_attributes

	
func get_chat_by_id(chat_id: String) -> Dictionary:
	if all_chats.has(chat_id):
		return all_chats[chat_id]
	else:
		print("CHAT ID NOT FOUND")
		return {}


func update_text(input_text:String)->void:
	#visible_characters = 0
	chat_scroll.text += "\n" + input_text
	
	#for i in get_parsed_text():
		#visible_characters += 1
		#await get_tree().create_timer(0.1).timeout
		
func push_chat():
	var chat = available_chats.pick_random()
	print(chat)
	available_chats.erase(chat)
	var chat_data = get_chat_by_id(chat)
	var text = chat_data.get("TEXT")
	var source = chat_data.get("SOURCE") + ": "
	var pair = chat_data.get("PAIR")
	var pair_text = chat_data.get("PAIR_TEXT")
	var pair_source = chat_data.get("PAIR_SOURCE")
	update_text(source + text)
	#if pair == true:
	if pair_text != null:
		pair_text = chat_data.get("PAIR_TEXT") + "[/indent]"
		pair_source = "[indent]" + chat_data.get("PAIR_SOURCE") + ": "
		var rand_pause = randf_range(1.0, 2.5)
		await get_tree().create_timer(rand_pause).timeout
		update_text(pair_source + pair_text)
	


func _on_button_pressed() -> void:
	var chat = available_chats.pick_random()
	print(chat)
	available_chats.erase(chat)
	var chat_data = get_chat_by_id(chat)
	var text = chat_data.get("TEXT")
	var source = chat_data.get("SOURCE") + ": "
	var pair = chat_data.get("PAIR")
	var pair_text = chat_data.get("PAIR_TEXT")
	var pair_source = chat_data.get("PAIR_SOURCE")
	update_text(source + text)
	#if pair == true:
	if pair_text != null:
		pair_text = chat_data.get("PAIR_TEXT") + "[/indent]"
		pair_source = "[indent]" + chat_data.get("PAIR_SOURCE") + ": "
		var rand_pause = randf_range(1.0, 2.5)
		await get_tree().create_timer(rand_pause).timeout
		update_text(pair_source + pair_text)
