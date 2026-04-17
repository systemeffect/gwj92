extends Node3D

@onready var animation_player: AnimationPlayer = $"Van Model/AnimationPlayer"
@onready var grid_screen: Node3D = $"Van Model/GridScreen"

var grid_van: Node2D
var current_anim: String = ""
var run_started: bool = false


func _ready() -> void:
	grid_van = grid_screen.find_child("City_Grid").find_child("Van")


func _process(_delta: float) -> void:
	if grid_van == null:
		return

	#Don't interrupt
	if animation_player.is_playing() and current_anim in ["start", "right", "left", "u-turn", "stop"]:
		return

	if !run_started and grid_van.is_currently_moving and !grid_van.is_turning:
		run_started = true
		play_anim("start")
		return

	if grid_van.is_turning:
		match grid_van.turn_direction:
			"right":
				play_anim("right")
			"left":
				play_anim("left")
			"u-turn":
				play_anim("u-turn")
		return

	if run_started and !grid_van.is_currently_moving and DirectionList.directions.size() <= 0:
		run_started = false
		play_anim("stop")
		return
	
	#Else
	play_anim("idle")


func play_anim(name: String) -> void:
	if current_anim != name:
		current_anim = name
		animation_player.play(name)
