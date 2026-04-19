extends Control
@export var first_level : PackedScene

@onready var tut_1: TextureRect = $Tut1
@onready var tut_2: TextureRect = $Tut2
@onready var tut_3: TextureRect = $Tut3
@onready var tut_4: TextureRect = $Tut4
@onready var tut_5: TextureRect = $Tut5

var slide = 1

func _ready() -> void:
	tut_1.show()
	tut_2.hide()
	tut_3.hide()
	tut_4.hide()
	tut_5.hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("confirm"):
		_on_continue_pressed()

func _on_continue_pressed() -> void:
	match slide:
		1:
			tut_2.show()
			slide += 1
		2:
			tut_3.show()
			slide += 1
		3:
			tut_4.show()
			slide += 1
		4:
			tut_5.show()
			slide += 1
		5:
			get_tree().change_scene_to_packed(first_level)
