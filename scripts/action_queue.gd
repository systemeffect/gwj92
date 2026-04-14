extends Control

signal action_removed


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
