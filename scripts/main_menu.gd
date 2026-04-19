extends CenterContainer

@export var first_level : PackedScene
@export var second_level : PackedScene
@export var third_level : PackedScene
@export var fourth_level : PackedScene
@onready var tutorial: Control = $"../../Tutorial"


@onready var start_button: Button = $Panel/Margin/Menu/StartButton
@onready var settings_button: Button = $Panel/Margin/Menu/SettingsButton
@onready var quit_button: Button = $Panel/Margin/Menu/QuitButton

@onready var settings_menu: CenterContainer = $"../SettingsMenu"

@onready var level_select: PanelContainer = $LevelSelect


func _ready() -> void:
	# for audio/sfx triggers when hovering over menu buttons
	#start_button.connect("mouse_entered", _on_mouse_button_entered)
	#settings_button.connect("mouse_entered", _on_mouse_button_entered)
	#quit_button.connect("mouse_entered", _on_mouse_button_entered)
	start_button.grab_focus()
	if AudioManager.music_menu.playing == false:
		AudioManager.music_menu.play()
	AudioManager.music_planning.stop()
	AudioManager.music_execute_1.stop()
	AudioManager.music_execute_2.stop()
	AudioManager.music_execute_3.stop()
	AudioManager.music_menu.finished.connect(_on_menu_music_finished)
	pass

func _on_menu_music_finished():
	AudioManager.music_menu.play()

func _on_mouse_button_entered() -> void:
	# for sfx when hovering over menu options
	pass

func _on_start_button_pressed() -> void:
	tutorial.show()


func _on_settings_button_pressed() -> void:
	settings_menu.show()
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_level_1_button_pressed() -> void:
	get_tree().change_scene_to_packed(first_level)

func _on_level_2_button_pressed() -> void:
	get_tree().change_scene_to_packed(second_level)
	
func _on_level_3_button_pressed() -> void:
	get_tree().change_scene_to_packed(third_level)

func _on_level_4_button_pressed() -> void:
	get_tree().change_scene_to_packed(fourth_level)
