extends Control

signal pressed

@export_enum("MOVEMENT", "INFORMATION", "OBJECTIVE", "INTERACTION") var card_type: String
@export_enum("UP", "DOWN", "LEFT", "RIGHT") var move_direction: String
@export_range(0.0, 5.0) var move_amount : int
@export var card_image: Texture

@onready var card_icon: TextureRect = $InnerBorder/CardIcon
@onready var card_button: Button = $CardButton
@onready var outer_border: ColorRect = $OuterBorder
@onready var details: PanelContainer = $Details
@onready var card_type_label: Label = $Details/MarginContainer/VBoxContainer/CardType
@onready var move_direction_label: Label = $Details/MarginContainer/VBoxContainer/MoveDirection
@onready var move_amount_label: Label = $Details/MarginContainer/VBoxContainer/MoveAmount
@onready var selected: Line2D = $Selected

var is_empty : bool = true

func _ready() -> void:
	selected.hide()
	outer_border.color = Color(0.06,0.06,0.06,1.0)
	card_button.mouse_entered.connect(_on_card_icon_mouse_entered)
	card_button.mouse_exited.connect(_on_card_icon_mouse_exited)
	card_icon.texture = card_image
	#set_card()
	
func _on_card_icon_mouse_entered():
	details.show()
	outer_border.color = Color(1.0,1.0,1.0,255)
	
func _on_card_icon_mouse_exited():
	details.hide()
	outer_border.color = Color(0.06,0.06,0.06,1.0)
	
func set_empty():
	card_icon.texture = null
	is_empty = true
	
#func set_card():
	#if is_empty:
		#if card_type == "MOVEMENT":
			#if move_direction == "UP":
				#
		#pass
	
