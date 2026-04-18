extends Node

# add onreadys for each sound file
@onready var sfx_button: AudioStreamPlayer = $SfxButton
@onready var sfx_engine_idle: AudioStreamPlayer = $SfxEngineIdle
@onready var sfx_engine_rev_down: AudioStreamPlayer = $SfxEngineRevDown
@onready var sfx_engine_rev_up: AudioStreamPlayer = $SfxEngineRevUp
@onready var sfx_engine_running: AudioStreamPlayer = $SfxEngineRunning
