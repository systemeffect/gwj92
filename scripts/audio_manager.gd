extends Node

# add onreadys for each sound file
@onready var sfx_button: AudioStreamPlayer = $SfxButton
@onready var sfx_engine_idle: AudioStreamPlayer = $SfxEngineIdle
@onready var sfx_engine_rev_down: AudioStreamPlayer = $SfxEngineRevDown
@onready var sfx_engine_rev_up: AudioStreamPlayer = $SfxEngineRevUp
@onready var sfx_engine_running: AudioStreamPlayer = $SfxEngineRunning

@onready var music_menu: AudioStreamPlayer = $MusicMenu
@onready var music_planning: AudioStreamPlayer = $MusicPlanning
@onready var music_execute_1: AudioStreamPlayer = $MusicExecute1
@onready var music_execute_2: AudioStreamPlayer = $MusicExecute2
@onready var music_execute_3: AudioStreamPlayer = $MusicExecute3
var exe_playlist = []
var current_track = 0

func _ready() -> void:
	exe_playlist.append(music_execute_3)
	exe_playlist.append(music_execute_2)
	exe_playlist.append(music_execute_1)
	exe_playlist.append(music_planning)
	music_execute_1.play()
	if !music_menu.playing:
		music_planning.stop()

		

func _on_finished() -> void:
	current_track = (current_track + 1) % exe_playlist.size()
	var next_song = exe_playlist[current_track]
	next_song.play()
