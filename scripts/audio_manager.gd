extends Node

# add onreadys for each sound file
@onready var sfx_engine_idle: AudioStreamPlayer = $SfxEngineIdle
@onready var sfx_engine_rev_down: AudioStreamPlayer = $SfxEngineRevDown
@onready var sfx_engine_rev_up: AudioStreamPlayer = $SfxEngineRevUp
@onready var sfx_engine_running: AudioStreamPlayer = $SfxEngineRunning

@onready var sfx_button: AudioStreamPlayer = $SfxButton
@onready var sfx_sensor_pickup: AudioStreamPlayer = $SfxSensorPickup

@onready var ui_cancel: AudioStreamPlayer = $UiCancel
@onready var ui_click: AudioStreamPlayer = $UiClick
@onready var ui_preview: AudioStreamPlayer = $UiPreview
@onready var ui_reset: AudioStreamPlayer = $UiReset
@onready var ui_rollout: AudioStreamPlayer = $UiRollout
@onready var ui_storm: AudioStreamPlayer = $UiStorm
