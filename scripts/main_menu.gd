extends CenterContainer

@export var first_level : PackedScene

@onready var start_button: Button = $Panel/Menu/StartButton
@onready var settings_button: Button = $Panel/Menu/SettingsButton
@onready var quit_button: Button = $Panel/Menu/QuitButton
@onready var settings_menu: CenterContainer = $"../SettingsMenu"

func _ready() -> void:
	# for audio/sfx triggers when hovering over menu buttons
	#start_button.connect("mouse_entered", _on_mouse_button_entered)
	#settings_button.connect("mouse_entered", _on_mouse_button_entered)
	#quit_button.connect("mouse_entered", _on_mouse_button_entered)
	
	
	pass



func _on_mouse_button_entered() -> void:
	# for sfx when hovering over menu options
	pass

func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	settings_menu.show()
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()
