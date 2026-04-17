extends Node3D

@export var van_body: Node3D
@export_enum("x", "y", "z") var wheel_axis: String = "z"

# Main mapping
@export var max_wheel_turn_degrees: float = 540.0
@export var max_body_lean_degrees: float = 15.0

# Spring / realism
@export var spring_strength: float = 18.0
@export var damping: float = 7.0
@export var overshoot_scale: float = 0.35

var base_rotation: Vector3
var wheel_angle: float = 0.0
var wheel_velocity: float = 0.0
var last_target_angle: float = 0.0


func _ready() -> void:
	base_rotation = rotation


func _process(delta: float) -> void:
	if van_body == null:
		return

	var body_lean_deg = rad_to_deg(van_body.rotation.z)
	var lean_ratio = clamp(body_lean_deg / max_body_lean_degrees, 1.0, -1.0)

	var target_angle = deg_to_rad(lean_ratio * max_wheel_turn_degrees)

	# Add a little "push" based on how fast the target is changing.
	# This helps create the overshoot feeling.
	var target_velocity = (target_angle - last_target_angle) / max(delta, 0.0001)
	last_target_angle = target_angle

	var spring_force = (target_angle - wheel_angle) * spring_strength
	var overshoot_force = target_velocity * overshoot_scale
	var damping_force = -wheel_velocity * damping

	wheel_velocity += (spring_force + overshoot_force + damping_force) * delta
	wheel_angle += wheel_velocity * delta

	match wheel_axis:
		"x":
			rotation = Vector3(base_rotation.x + wheel_angle, base_rotation.y, base_rotation.z)
		"y":
			rotation = Vector3(base_rotation.x, base_rotation.y + wheel_angle, base_rotation.z)
		"z":
			rotation = Vector3(base_rotation.x, base_rotation.y, base_rotation.z + wheel_angle)
