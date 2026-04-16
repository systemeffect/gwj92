extends Node3D

@onready var animation_player: AnimationPlayer = $"Van Model/AnimationPlayer"
@onready var grid_screen: Node3D = $"Van Model/GridScreen"

var grid_van: Node2D
var current_anim: String = ""

func _ready() -> void:
	grid_van = grid_screen.find_child("City_Grid").find_child("Van")
	
func _process(delta: float) -> void:
	if grid_van.is_turning:
		match grid_van.turn_direction:
			"right":
				play_anim("right")
			"left":
				play_anim("left")
			"u-turn":
				play_anim("u-turn")

	elif grid_van.is_not_moving and DirectionList.directions.size() <= 0:
		play_anim("stop")

func play_anim(name: String):
	if current_anim != name:
		current_anim = name
		animation_player.play(name)
