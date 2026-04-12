extends Control

@onready var action_1: Control = $GridContainer/Action_1
@onready var action_2: Control = $GridContainer/Action_2
@onready var action_3: Control = $GridContainer/Action_3
@onready var action_4: Control = $GridContainer/Action_4

var queue_size : int = 0
var max_queue_size : int = 4
var current_queue : Array
var queue_item_1 : Dictionary
var queue_item_2 : Dictionary
var queue_item_3 : Dictionary
var queue_item_4 : Dictionary
var selected_action : String

var action_ui : Control

func _ready() -> void:
	action_ui = get_parent().find_child("ActionsUI")
	action_ui.action_queued.connect(_on_action_queued)
	action_ui.action_removed.connect(_on_action_removed)
	
func _on_action_queued(card_id : String):
	if queue_size < max_queue_size:
		current_queue.append(card_id)
		queue_size += 1
	else:
		print("Action Queue Full")
	clear_queue_window()
	update_queue()
	
func _on_action_removed(card_id : String):
	current_queue.erase(selected_action)
	queue_size -= 1
	clear_queue_window()
	update_queue()
	
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
	pass
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
			
func _on_pressed(card_id : String):
	if selected_action != card_id:
		selected_action = card_id
	else:
		selected_action = ""
