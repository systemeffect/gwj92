extends CharacterBody3D

@onready var camera_pivot: Node3D = $CameraPivot
@onready var ray_cast_3d: RayCast3D = $CameraPivot/RayCast3D
@onready var button_anim_player: AnimationPlayer = $"../Van/Van Model/RedButton/AnimationPlayer"

var mouse_motion := Vector2.ZERO
var is_mouse_visible: bool = false

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	#var scene = load("res://City_Grid/city_grid.tscn")
	#var instance = scene.instantiate()
	#sub_viewport.add_child(instance)
	
func _physics_process(delta: float) -> void:
	
	# Handle camera rotation.
	handle_camera_rotation()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.001
			
	if event.is_action_pressed("ui_cancel"):
		if !is_mouse_visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			is_mouse_visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			is_mouse_visible = false
	
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			
			#Probably not the best way to do this but whatever
			if ray_cast_3d.is_colliding():
				if ray_cast_3d.get_collider().name == "ButtonArea":
					GlobalSignals.red_button_pressed.emit()
					button_anim_player.play("button_press")
				if ray_cast_3d.get_collider().name == "GridScreenArea":
					GlobalSignals.grid_screen_pressed.emit()

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	# Clamp the camera's vertical rotation.
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO

func make_mouse_visible() -> void:
	if !is_mouse_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_mouse_visible = true
