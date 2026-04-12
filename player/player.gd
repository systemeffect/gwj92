extends CharacterBody3D

@onready var sub_viewport: SubViewport = $"../MeshInstance3D/SubViewport"
@onready var camera_pivot: Node3D = $CameraPivot
@onready var mesh_instance_3d: MeshInstance3D = $"../MeshInstance3D"

var mouse_motion := Vector2.ZERO

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
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	
	if event is InputEventMouseButton:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			GlobalSignals.clicked.emit()

func handle_camera_rotation() -> void:
	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	# Clamp the camera's vertical rotation.
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO
