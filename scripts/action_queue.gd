extends Control

#signal action_removed

#@onready var action_1: Control = $GridContainer/Action_1
#@onready var action_2: Control = $GridContainer/Action_2
#@onready var action_3: Control = $GridContainer/Action_3
#@onready var action_4: Control = $GridContainer/Action_4

var queue_size : int = 0
var max_queue_size : int = 4
var current_queue : Array
var queue_item_1 : Dictionary
var queue_item_2 : Dictionary
var queue_item_3 : Dictionary
var queue_item_4 : Dictionary
var selected_action : String

var action_ui : Control

func _on_pressed(card_id : String):
	if selected_action != card_id:
		selected_action = card_id
	else:
		selected_action = ""
