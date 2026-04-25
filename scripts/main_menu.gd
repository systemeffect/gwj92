extends CenterContainer

@export var first_level : PackedScene

@onready var tutorial: Control = $"../../Tutorial"


@onready var start_button: Button = $Panel/Margin/Menu/StartButton
@onready var settings_button: Button = $Panel/Margin/Menu/SettingsButton
@onready var quit_button: Button = $Panel/Margin/Menu/QuitButton

@onready var settings_menu: CenterContainer = $"../SettingsMenu"

@onready var level_select: PanelContainer = $LevelSelect

var has_tutorial_played : bool = false

func _ready() -> void:
	# for audio/sfx triggers when hovering over menu buttons
	#start_button.connect("mouse_entered", _on_mouse_button_entered)
	#settings_button.connect("mouse_entered", _on_mouse_button_entered)
	#quit_button.connect("mouse_entered", _on_mouse_button_entered)
	#start_button.grab_focus()
	AudioManager.music_planning.stop()
	AudioManager.music_execute_1.stop()
	AudioManager.music_execute_2.stop()
	AudioManager.music_execute_3.stop()
	if AudioManager.music_menu.playing == false:
		AudioManager.music_menu.play()

	AudioManager.music_menu.finished.connect(_on_menu_music_finished)
	pass

func _on_menu_music_finished():
	AudioManager.music_menu.play()

func _on_mouse_button_entered() -> void:
	# for sfx when hovering over menu options
	pass

func _on_start_button_pressed() -> void:
	#if !has_tutorial_played:
		#tutorial.show()
		#has_tutorial_played = true
	#else:
		#get_tree().change_scene_to_packed(first_level)
	Util.current_level_index = 1
	get_tree().change_scene_to_packed(first_level)


func _on_settings_button_pressed() -> void:
	settings_menu.show()
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	get_tree().quit()



func _on_jam_level_pressed() -> void:
	Util.current_level_index = 1
	get_tree().change_scene_to_packed(first_level)

func _on_four_corners_pressed() -> void:
	Util.current_level_index = 2
	get_tree().change_scene_to_packed(first_level)

func _on_urban_sprawl_pressed() -> void:
	Util.current_level_index = 3
	get_tree().change_scene_to_packed(first_level)

func _on_choppy_pressed() -> void:
	Util.current_level_index = 4
	get_tree().change_scene_to_packed(first_level)

func _on_commute_pressed() -> void:
	Util.current_level_index = 5
	get_tree().change_scene_to_packed(first_level)

func _on_maze_pressed() -> void:
	Util.current_level_index = 6
	get_tree().change_scene_to_packed(first_level)

func _on_bonus_pressed() -> void:
	Util.current_level_index = 7
	get_tree().change_scene_to_packed(first_level)

func _on_timorous_pressed() -> void:
	Util.current_level_index = 8
	get_tree().change_scene_to_packed(first_level)

func _on_solar_pressed() -> void:
	Util.current_level_index = 9
	get_tree().change_scene_to_packed(first_level)

func _on_starburst_pressed() -> void:
	Util.current_level_index = 10
	get_tree().change_scene_to_packed(first_level)


func _on_level_select_button_pressed() -> void:
	level_select.show()
