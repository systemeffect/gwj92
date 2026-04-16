extends Control

signal pressed

@export_enum("MOVEMENT", "ATTRIBUTE") var card_type: String
@export_enum("UP", "DOWN", "LEFT", "RIGHT") var move_direction: String
@export_range(0.0, 5.0) var move_amount : int
@export var card_image: Texture
@export var is_in_action_queue : bool = false
@export_range(1,3) var queue_number : int

@onready var card_icon: TextureRect = $InnerBorder/CardIcon
@onready var card_nullify: TextureRect = $InnerBorder/CardNullify
@onready var card_button: Button = $CardButton
@onready var outer_border: ColorRect = $OuterBorder
@onready var details: PanelContainer = $Details
@onready var card_type_label: Label = $Details/MarginContainer/VBoxContainer/CardType
@onready var heading: Label = $Details/MarginContainer/VBoxContainer/Heading
@onready var subheading: Label = $Details/MarginContainer/VBoxContainer/Subheading
@onready var card_id: Label = $Details/MarginContainer/VBoxContainer/CardID


@onready var selected: Line2D = $Selected
@onready var action_queue_num: Label = $InnerBorder/ActionQueueNum

var outer_border_default_color = Color(0.06,0.06,0.06,1.0)
var icon_path : String = "res://assets/icons/"
var card : Dictionary
var is_empty : bool = true

func _ready() -> void:
	#if is_in_action_queue:
		#action_queue_num.show()
		#action_queue_num.text = "Action " + str(queue_number)
	#else:
		#action_queue_num.hide()
	card_nullify.hide()
	selected.hide()
	outer_border.color = Color(0.06,0.06,0.06,1.0)
	card_button.mouse_entered.connect(_on_card_icon_mouse_entered)
	card_button.mouse_exited.connect(_on_card_icon_mouse_exited)
	card_icon.texture = card_image
	#set_card()
	
func _on_card_icon_mouse_entered():
	if !is_in_action_queue:
		details.show()
		outer_border.color = Color(1.0,1.0,1.0,255)
	
func _on_card_icon_mouse_exited():
	details.hide()
	outer_border.color = outer_border_default_color
	
func set_empty():
	card_icon.texture = null
	is_empty = true
	card = {}
	
func deselect():
	selected.hide()
	
func toggle_nullify(on: bool):
	if on:
		card_nullify.show()
	else:
		card_nullify.hide()
	
func set_card(new_card : Dictionary):
	if new_card != null:
		card = new_card
		if card.get("CARD_ICON") != null:
			var new_card_icon_path = icon_path + card.get("CARD_ICON")
			card_icon.texture = load(new_card_icon_path)
		card_type_label.text = card["CARD_TYPE"]
		heading.text = card["DESCRIPTION_HEADING"]
		subheading.text = str(card["DESCRIPTION_SUBHEADING"])
		card_id.text = "Card ID: " + str(card["ID"])
		#set_storm_color()
	
func set_storm_color():
	if !is_in_action_queue:
		var storm_type = card.get("STORM_TYPE")
		match storm_type:
			"DEBRIS":
				outer_border_default_color = Color(0.488, 0.468, 0.079, 1.0)
				outer_border.color = outer_border_default_color
			"FIRE":
				outer_border_default_color = Color(1.0, 0.176, 0.255, 1.0)
				outer_border.color = outer_border_default_color
			"FLOOD":
				outer_border_default_color = Color(0.196, 0.079, 0.928, 1.0)
				outer_border.color = outer_border_default_color
			"WIND":
				outer_border_default_color = Color(0.129, 0.471, 0.361, 1.0)
				outer_border.color = outer_border_default_color
			"CALM":
				outer_border_default_color = Color(0.807, 0.869, 0.974, 1.0)
				outer_border.color = outer_border_default_color

func set_active_border_color():
	outer_border.color = Color(0.938, 0.425, 0.0, 1.0)
	
func set_default_border_color():
	outer_border.color = outer_border_default_color

func _on_card_button_pressed() -> void:
	if !selected.visible:
		for slot in get_parent().get_children():
			slot.deselect()
		selected.show()
		pressed.emit()
	else:
		selected.hide()
