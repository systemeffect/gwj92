extends CharacterBody3D

@export var screen_width_multiplier: float = 1.0
@export var screen_height_multiplier: float = 1.0
@export var screen_x_offset: float = 0.0
@export var screen_y_offset: float = 0.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var ray_cast_3d: RayCast3D = $CameraPivot/RayCast3D
@onready var button_anim_player: AnimationPlayer = $"../Van/Van Model/RedButton/AnimationPlayer"

var mouse_motion := Vector2.ZERO
var is_mouse_visible: bool = false

var sub_viewport: SubViewport
var grid_screen: Node3D
var grid_screen_area: Area3D
var screen_sprite: Sprite3D

var last_screen_pos: Vector2 = Vector2.ZERO
var cursor_over_screen: bool = false


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	var parent = get_parent()
	if parent != null:
		grid_screen = parent.get_node("Van/Van Model/GridScreen")
		sub_viewport = grid_screen.get_node("SubViewport")
		grid_screen_area = grid_screen.get_node("GridScreenArea")
		screen_sprite = grid_screen.get_node("Sprite3D")

func _physics_process(_delta: float) -> void:
	handle_camera_rotation()

func _process(_delta: float) -> void:
	var parent = get_parent()
	if parent == null:
		return

	if parent.screen_view_active and sub_viewport != null and grid_screen_area != null and screen_sprite != null:
		var hit = get_screen_hit_from_mouse()

		if !hit.is_empty():
			var viewport_pos = map_3d_hit_to_2d_screen(hit.position)
			if viewport_pos.x >= 0.0 and viewport_pos.y >= 0.0:
				cursor_over_screen = true
				last_screen_pos = viewport_pos
				send_mouse_motion_to_screen(viewport_pos)
			else:
				cursor_over_screen = false
		else:
			cursor_over_screen = false
	else:
		cursor_over_screen = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			mouse_motion = -event.relative * 0.001

	if event.is_action_pressed("ui_close_dialog"):
		GlobalSignals.escape_key.emit()
		if !is_mouse_visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			is_mouse_visible = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			is_mouse_visible = false
			if get_parent().screen_view_active:
				get_parent().player_leave_screen()

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if get_parent().screen_view_active:
			if event.pressed and cursor_over_screen and sub_viewport != null:
				activate_hovered_screen_button()
				get_viewport().set_input_as_handled()
				return

		# Normal world interaction when not zoomed in
		if event.pressed:
			if ray_cast_3d.is_colliding():
				var collider = ray_cast_3d.get_collider()
				if collider != null:
					if collider.name == "ButtonArea":
						GlobalSignals.red_button_pressed.emit()
						button_anim_player.play("button_press")
						AudioManager.sfx_button.play()

					if collider.name == "GridScreenArea":
						GlobalSignals.grid_screen_pressed.emit()


func handle_camera_rotation() -> void:
	if get_parent().screen_view_active:
		mouse_motion = Vector2.ZERO
		return

	rotate_y(mouse_motion.x)
	camera_pivot.rotate_x(mouse_motion.y)
	camera_pivot.rotation_degrees.x = clampf(camera_pivot.rotation_degrees.x, -90.0, 90.0)
	mouse_motion = Vector2.ZERO


func make_mouse_visible() -> void:
	if !is_mouse_visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		is_mouse_visible = true


func get_screen_hit_from_mouse() -> Dictionary:
	if grid_screen_area == null:
		return {}

	var camera: Camera3D = get_viewport().get_camera_3d()
	if camera == null:
		return {}

	var mouse_pos: Vector2 = get_viewport().get_mouse_position()
	var ray_origin: Vector3 = camera.project_ray_origin(mouse_pos)
	var ray_dir: Vector3 = camera.project_ray_normal(mouse_pos)
	var ray_end: Vector3 = ray_origin + ray_dir * 100.0

	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	query.collide_with_areas = true
	query.collide_with_bodies = false

	var result = space_state.intersect_ray(query)

	if result.is_empty():
		return {}

	if result.collider != grid_screen_area:
		return {}

	return result


func map_3d_hit_to_2d_screen(hit_pos: Vector3) -> Vector2:
	if screen_sprite == null or sub_viewport == null:
		return Vector2(-1, -1)

	# Convert hit point into local coordinates of the visible Sprite3D
	var local_hit: Vector3 = screen_sprite.to_local(hit_pos)

	# Sprite3D is centered, so local x/y ranges roughly from -pixel_size/2 to +pixel_size/2 in local units.
	# We use the sprite's pixel_size and texture dimensions to compute world size.
	var tex: Texture2D = screen_sprite.texture
	if tex == null:
		return Vector2(-1, -1)

	var screen_width: float = tex.get_width() * screen_sprite.pixel_size * screen_width_multiplier
	var screen_height: float = tex.get_height() * screen_sprite.pixel_size * screen_height_multiplier

	var u = (local_hit.x / screen_width) + 0.5 + screen_x_offset
	var v = (-local_hit.y / screen_height) + 0.5 + screen_y_offset + 0.5

	if u < 0.0 or u > 1.0 or v < 0.0 or v > 1.0:
		return Vector2(-1, -1)

	return Vector2(
		u * sub_viewport.size.x,
		v * sub_viewport.size.y
	)
	
func send_mouse_motion_to_screen(viewport_pos: Vector2) -> void:
	var motion := InputEventMouseMotion.new()
	motion.position = viewport_pos
	motion.global_position = viewport_pos
	sub_viewport.push_input(motion, true)
	
func activate_hovered_screen_button() -> void:
	var hovered := sub_viewport.gui_get_hovered_control()

	if hovered == null:
		print("No hovered control")
		return

	print("Activating hovered control: ", hovered.get_path())

	if hovered is BaseButton:
		hovered.pressed.emit()
