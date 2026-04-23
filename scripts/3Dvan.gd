extends Node3D

@onready var animation_player: AnimationPlayer = $"Van Model/AnimationPlayer"
@onready var grid_screen: Node3D = $"Van Model/GridScreen"

var grid_van: Node2D
var current_anim: String = ""
var current_engine_sfx: String = ""
var run_started: bool = false


func _ready() -> void:
	grid_van = grid_screen.find_child("City_Grid").find_child("Van")


func _process(_delta: float) -> void:
	if grid_van == null:
		return
	# Don't interrupt one-shot animations
	if animation_player.is_playing() and current_anim in ["start", "right", "left", "u-turn", "stop"]:
		return
	# Start of run
	if !run_started and grid_van.is_currently_moving and !grid_van.is_turning:
		run_started = true
		play_anim("start")
		play_engine_sfx("rev_up")
		return
	# Turning
	if grid_van.is_turning:
		match grid_van.turn_direction:
			"right":
				play_anim("right")
				#AudioManager..play()
			"left":
				play_anim("left")
				#AudioManager..play()
			"u-turn":
				play_anim("u-turn")
				#AudioManager..play()
		return
	# Running straight during a run
	if run_started and grid_van.is_currently_moving:
		play_anim("idle")
		play_engine_sfx("running")
		return
	# End of run
	if run_started and !grid_van.is_currently_moving and DirectionList.directions.size() <= 0:
		run_started = false
		play_anim("stop")
		play_engine_sfx("rev_down")
		return
		
	# Default idle
	play_anim("idle")
	play_engine_sfx("idle")

func play_anim(name: String) -> void:
	if current_anim != name:
		current_anim = name
		animation_player.play(name)

func play_engine_sfx(name: String) -> void:
	if current_engine_sfx == name:
		return
	current_engine_sfx = name
	# Stop all engine sounds first
	AudioManager.sfx_engine_idle.stop()
	AudioManager.sfx_engine_rev_up.stop()
	AudioManager.sfx_engine_rev_down.stop()
	AudioManager.sfx_engine_running.stop()
	match name:
		"idle":
			AudioManager.sfx_engine_idle.play()
		"rev_up":
			AudioManager.sfx_engine_rev_up.play()
		"rev_down":
			AudioManager.sfx_engine_rev_down.play()
		"running":
			AudioManager.sfx_engine_running.play()
