extends CenterContainer


@onready var master_vol_slider: HSlider = $Panel/Margin/VBoxContainer/MasterVolSlider
@onready var music_vol_slider: HSlider = $Panel/Margin/VBoxContainer/MusicVolSlider
@onready var sfx_vol_slider: HSlider = $Panel/Margin/VBoxContainer/SFXVolSlider

func _ready() -> void:
	master_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	music_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_vol_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

func _on_back_button_pressed() -> void:
	hide()
	pass # Replace with function body.

func _on_master_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Master"), value)

func _on_music_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("Music"), value)
	
func _on_sfx_vol_slider_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_linear(AudioServer.get_bus_index("SFX"), value)
